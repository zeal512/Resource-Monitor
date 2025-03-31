package com.example.Metrics;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ExecutionException;
import java.util.stream.Collectors;
import org.springframework.context.annotation.Bean;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
//import org.junit.jupiter.api.Test;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
//import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.web.bind.annotation.GetMapping;

import org.springframework.web.bind.annotation.RestController;
import oshi.SystemInfo;
import oshi.hardware.HWDiskStore;
import oshi.hardware.HardwareAbstractionLayer;
import oshi.hardware.NetworkIF;
import oshi.software.os.OSProcess;
import oshi.software.os.OperatingSystem;
import oshi.util.Util;

@SpringBootApplication
@RestController
public class DemoApplication {
    private final SystemInfo systemInfo = new SystemInfo();
    private final HardwareAbstractionLayer hardware = systemInfo.getHardware();
    private final OperatingSystem os = systemInfo.getOperatingSystem();
    public static void main(String[] args) {
      SpringApplication.run(DemoApplication.class, args);
    }
    public class ProcessInfo {
      private String name;
      public String getName() {
          return name;
      }
  
      public void setName(String name) {
          this.name = name;
      }
  
      public String getMemoryUsage() {
          return memoryUsage;
      }
  
      public void setMemoryUsage(String memoryUsage) {
          this.memoryUsage = memoryUsage;
      }
  
      public String getNetworkUsage() {
          return networkUsage;
      }
  
      public void setNetworkUsage(String networkUsage) {
          this.networkUsage = networkUsage;
      }
  
      private String memoryUsage;
      private String networkUsage;
  
      public ProcessInfo(String name, String memoryUsage, String networkUsage) {
          this.name = name;
          this.memoryUsage = memoryUsage;
          this.networkUsage = networkUsage;
      }
  
      @Override
      public String toString() {
          return "Name: " + name + ", Memory Usage: " + memoryUsage + ", Network Usage: " + networkUsage;
      }
  }
  private List<ProcessInfo> getTopProcesses() throws IOException {
    List<ProcessInfo> processList = new ArrayList<>();

    String[] command = { "cmd.exe", "/c", "top -l 1 -n 11 -o mem" };
    Process process = Runtime.getRuntime().exec(command);

    try (BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
        String line;
        while ((line = bufferedReader.readLine()) != null) {
            if (line.trim().startsWith("PID")) {
                break; 
            }
        }

        while ((line = bufferedReader.readLine()) != null) {
            if (line.trim().isEmpty()) {
                break; // End of process list reached
            }

            String[] columns = line.trim().split("\s+");

            if (columns.length >= 12) {
                String commandName = columns[1]; 
                String memoryUsage = columns[7];
               String networkUsage = columns[10]; 
                processList.add(new ProcessInfo(commandName, memoryUsage, networkUsage));
            }
        }
    } catch (IOException e) {
        System.out.println("Error reading top processes: " + e.getMessage());
        throw e;
    }

    return processList;
}
public class ProcessService {
  public CompletableFuture<List<OSProcess>> getProcessesAsync(OperatingSystem os) {
      return CompletableFuture.supplyAsync(() -> {
          List<OSProcess> processes = os.getProcesses();
          processes.sort(Comparator.comparingLong(OSProcess::getResidentSetSize).reversed());
          processes = processes.stream().limit(5).collect(Collectors.toList());

          return processes;
      });
  }
}
    @GetMapping("/systemMetrics")
    public Stats systemMetrics() throws IOException, InterruptedException, ExecutionException {
      //OperatingSystemMXBean operatingSystemMXBean = ManagementFactory.getOperatingSystemMXBean();
      //double cpuUsage = 100.0;
      double cpuUsage = hardware.getProcessor().getSystemCpuLoad(500)*100 ;
      long totalMemory = hardware.getMemory().getTotal();
      long availableMemory = hardware.getMemory().getAvailable();
      HWDiskStore disk = new SystemInfo().getHardware().getDiskStores().get(0);
      List<NetworkIF> networkIFs = hardware.getNetworkIFs();
      //NetworkIF networkIF = hardware.getNetworkIFs().get(1);
      long startRead = disk.getReads();
      long startWrite = disk.getWrites();
      long startTransfer = disk.getTransferTime();
      long startTimeStamp = disk.getTimeStamp();
      long startBytesSent = 0;
      long startBytesReceived = 0;
      for (NetworkIF networkIF : networkIFs) {
        // Accumulate total received and transmitted bytes
        startBytesSent += networkIF.getBytesRecv();
        startBytesReceived += networkIF.getBytesSent();
      }
      
      Util.sleep(5000);
      disk.updateAttributes();
      long endRead = disk.getReads() - startRead;
      long endWrite = disk.getWrites() - startWrite;
      double endTransfer = disk.getTransferTime() - startTransfer;

      double endTimeStamp = disk.getTimeStamp() - startTimeStamp;
      for (NetworkIF networkIF : networkIFs) {
        networkIF.updateAttributes();
      }
      long endBytesSent = 0;
      long endBytesReceived = 0;
      for (NetworkIF networkIF : networkIFs) {
      // Accumulate total received and transmitted bytes
        endBytesSent += networkIF.getBytesRecv();
        endBytesReceived += networkIF.getBytesSent();
      }
      
      endBytesSent-=startBytesSent;
      endBytesReceived-=startBytesReceived;
      
      //networkIFs.updateAttributes();
      //long endBytesSent = networkIF.getBytesSent() - startBytesSent;
      //long endBytesReceived = networkIF.getBytesRecv() - startBytesReceived;
      

      double percentUsed = (endTransfer/endTimeStamp)*100;
      double bytesSentPerSec = endBytesSent/5;
      double bytesReceivedPerSec = endBytesReceived/5;
      
      //List<OSProcess> processes = os.getProcesses();
      //processes.sort(Comparator.comparingLong(OSProcess::getResidentSetSize).reversed());
      //processes = processes.stream().limit(10).collect(Collectors.toList());
      ProcessService processService = new ProcessService();

      
      return new Stats(totalMemory,availableMemory,cpuUsage,endRead,endWrite,percentUsed,bytesSentPerSec, bytesReceivedPerSec, processService.getProcessesAsync(os).get() ) ;
    }

    @Bean
public WebMvcConfigurer corsConfigurer() {
    return new WebMvcConfigurer() {
        @Override
        public void addCorsMappings(CorsRegistry registry) {
            registry.addMapping("/**").allowedOrigins("http://localhost:5500");
        }
    };
}
      static class Stats{
        private long totalMemory;
        private long availableMemory;
        private double cpuUsage;
        private long reads;
        private long writes;
        private double percentUsed;
        private double bytesSentPerSec;
        private double bytesReceivedPerSec;
        private List<OSProcess> processorList;
        //private List<DemoApplication.ProcessInfo> processorList;

        public Stats(long totalMemory, long availableMemory, double cpuUsage, long reads,long writes,double percentUsed, double bytesSentPerSec, double bytesReceivedPerSec, List<OSProcess> processorList) {
              this.totalMemory = totalMemory;
              this.availableMemory = availableMemory;
              this.cpuUsage = cpuUsage;
              this.reads = reads;
              this.writes=writes;
              this.percentUsed=percentUsed;
              this.bytesSentPerSec=bytesSentPerSec;
              this.bytesReceivedPerSec=bytesReceivedPerSec;
              this.processorList = processorList;
        }
        public long getTotalMemory() {
          return totalMemory;
        }
        public long getAvailableMemory() {
          return availableMemory;
        }
        public double getCpuUsage() {
          return cpuUsage;
        }
        public long getReads() {
          return reads;
        }
        public long getWrites() {
          return writes;
        }
        public double getPercentUsed() {
          return percentUsed;
        }
        public double getBytesSentPerSec() {
          return bytesSentPerSec;
        }
        public double getBytesReceivedPerSec() {
          return bytesReceivedPerSec;
        }
        public List<OSProcess> getProcessorList() {
          return processorList;
        }

    }

}