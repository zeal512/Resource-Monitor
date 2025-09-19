# Resource Monitor Web Application

## Overview

The Resource Monitor web application is designed to offer users an intuitive interface to monitor and comprehend critical system metrics in real-time. It provides insights into CPU usage, memory usage, disk usage, and the top 10 processes by memory usage. Additionally, it offers visual representations of system metrics through interactive charts.

## Features

- **Real-time System Monitoring**: Monitor CPU usage, memory usage, and system processes
- **Interactive Charts**: Visual representation of system metrics using Chart.js
- **Process Information**: Display top 10 processes by memory usage
- **Cross-platform Support**: Works on Windows, macOS, and Linux
- **Modern UI**: Bootstrap-based responsive design

## Technology Stack

- **Backend**: Java 17, Jakarta Servlet API, JSP
- **Frontend**: HTML5, CSS3, JavaScript, Bootstrap 5, Chart.js
- **Build Tool**: Maven
- **Server**: Apache Tomcat 10+

## Installation

### Prerequisites

- Java 17 or higher
- Apache Tomcat 10+ (or any Jakarta EE compatible server)
- Maven 3.6+

### Build and Deploy

1. **Clone the repository**:
   ```bash
   git clone https://github.com/zeal512/Resource-Monitor.git
   cd Resource-Monitor
   ```

2. **Build the project**:
   ```bash
   mvn clean package
   ```

3. **Deploy to Tomcat**:
   - Copy the generated `target/activity-monitor-1.0-SNAPSHOT.war` file to your Tomcat `webapps` directory
   - Start Tomcat server

4. **Access the application**:
   - Open your browser and navigate to `http://localhost:8080/activity-monitor-1.0-SNAPSHOT/ActivityMonitor.jsp`

## Usage

1. **Launch Monitor**: Click the "Launch Monitor" button on the main page
2. **View Results**: The application will display:
   - System information (OS, CPU usage, memory statistics)
   - Interactive pie charts for CPU, heap memory, non-heap memory, and physical memory
   - Bar chart showing system metrics summary
   - Table of top 10 processes by memory usage

## Project Structure

```
src/
├── main/
│   ├── java/
│   │   └── ActivityMonitor/
│   │       ├── ActivityMonitorAction.java    # Main servlet handling system monitoring
│   │       └── ProcessInfo.java              # Process data model
│   └── webapp/
│       ├── ActivityMonitor.jsp               # Main entry page
│       ├── result.jsp                        # Results display page
│       ├── error.jsp                         # Error handling page
│       └── WEB-INF/
│           └── web.xml                       # Web application configuration
├── pom.xml                                   # Maven configuration
└── README.md                                 # This file
```

## Key Improvements

- **Enhanced CPU Calculation**: Implemented multiple sampling approach for accurate CPU usage monitoring
- **JSTL Integration**: Fixed taglib configuration for proper JSP functionality
- **Robust Error Handling**: Added comprehensive error handling and fallback mechanisms
- **Debug Logging**: Enhanced logging for better troubleshooting and monitoring

## System Requirements

- **Java**: JDK 17 or higher
- **Memory**: Minimum 512MB RAM
- **Disk Space**: 50MB for application files
- **Browser**: Modern web browser with JavaScript enabled

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is open source and available under the [MIT License](LICENSE).

## Author

**Zeal Shah**
- GitHub: [@zeal512](https://github.com/zeal512)

## Acknowledgments

- Built as part of Operating System Design course project
- Uses Chart.js for data visualization
- Bootstrap for responsive UI design
