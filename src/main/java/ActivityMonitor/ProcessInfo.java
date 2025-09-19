package ActivityMonitor;

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