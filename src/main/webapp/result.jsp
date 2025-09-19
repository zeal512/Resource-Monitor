<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Activity Monitor - Results</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.jsdelivr.net/npm/chart.js@3.9.1/dist/chart.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-datalabels@2.0.0"></script>
    <style>
        body { background-color: #f8f9fa; font-family: 'Arial', sans-serif; }
        .container { margin-top: 40px; margin-bottom: 40px; }
        .card { box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15); border-radius: 12px; margin-bottom: 25px; transition: transform 0.2s; }
        .card:hover { transform: translateY(-5px); }
        .table { background-color: #fff; font-size: 0.9rem; }
        .table th, .table td { vertical-align: middle; }
        .table .process-name { max-width: 200px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
        .chart-container { max-width: 400px; margin: 0 auto 20px; padding: 20px; position: relative; height: 300px; }
        .chart-container canvas { width: 100% !important; height: 100% !important; }
        .bar-chart-container { max-width: 100%; margin: 0 auto; padding: 20px; position: relative; }
        .bar-chart-container canvas { width: 100% !important; height: 400px !important; max-height: 50vh; }
        .btn-secondary { transition: background-color 0.2s; }
        .btn-secondary:hover { background-color: #6c757d; }
    </style>
</head>
<body>
    <div class="container">
        <h1 class="text-center mb-5 fw-bold">Activity Monitor Results</h1>
        
        <!-- System Information -->
        <div class="card p-4">
            <h3 class="card-title mb-3">System Information</h3>
            <div class="row">
                <div class="col-md-6">
                    <p><strong>Operating System:</strong> ${osName}</p>
                    <p><strong>CPU Usage:</strong> ${cpuUsage}%</p>
                    <p><strong>Heap Memory Used:</strong> ${heapMemoryUsed} GB</p>
                    <p><strong>Heap Memory Available:</strong> ${heapMemoryAvailable} GB</p>
                    <p><strong>Non-Heap Memory Used:</strong> ${nonHeapMemoryUsed} GB</p>
                    <p><strong>Non-Heap Memory Available:</strong> ${nonHeapMemoryAvailable} GB</p>
                </div>
                <div class="col-md-6">
                    <p><strong>Total Heap Memory:</strong> ${heapMemoryMax} GB</p>
                    <p><strong>Total Non-Heap Memory:</strong> ${nonHeapMemoryMax} GB</p>
                    <p><strong>Total Physical Memory:</strong> ${totalPhysicalMemory} GB</p>
                    <p><strong>Available Physical Memory:</strong> ${availablePhysicalMemory} GB</p>
                    <p><strong>In Use Physical Memory:</strong> ${inUsePhysicalMemory} GB</p>
                </div>
            </div>
            <c:if test="${empty cpuUsage}">
                <p style="color:red">Debug: No system data available. Check server logs.</p>
            </c:if>
        </div>

        <!-- Pie Chart for CPU Usage -->
        <div class="card p-4">
            <h3 class="card-title text-center mb-4">CPU Usage</h3>
            <div class="chart-container">
                <canvas id="cpuPieChart"></canvas>
            </div>
        </div>

        <!-- Pie Chart for Heap Memory -->
        <div class="card p-4">
            <h3 class="card-title text-center mb-4">Heap Memory</h3>
            <div class="chart-container">
                <canvas id="heapPieChart"></canvas>
            </div>
        </div>

        <!-- Pie Chart for Non-Heap Memory -->
        <div class="card p-4">
            <h3 class="card-title text-center mb-4">Non-Heap Memory</h3>
            <div class="chart-container">
                <canvas id="nonHeapPieChart"></canvas>
            </div>
        </div>

        <!-- Pie Chart for Physical Memory -->
        <div class="card p-4">
            <h3 class="card-title text-center mb-4">Physical Memory</h3>
            <div class="chart-container">
                <canvas id="physicalPieChart"></canvas>
            </div>
        </div>

        <!-- Bar Chart for System Metrics -->
        <div class="card p-4">
            <h3 class="card-title text-center mb-4">System Metrics Summary</h3>
            <div class="bar-chart-container">
                <canvas id="systemMetricsChart"></canvas>
            </div>
        </div>

        <!-- Top Processes Table -->
        <div class="card p-4">
            <h3 class="card-title mb-3">Top 10 Processes by Memory Usage</h3>
            <table class="table table-striped table-hover">
                <thead class="table-dark">
                    <tr>
                        <th scope="col" class="process-name">Name</th>
                        <th scope="col">Memory Usage</th>
                        <th scope="col">Network Usage</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty topProcessesList}">
                            <c:forEach var="process" items="${topProcessesList}">
                                <tr>
                                    <td class="process-name" title="${process.name}">${process.name}</td>
                                    <td>${process.memoryUsage} GB</td>
                                    <td>${process.networkUsage} MB/s</td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="3" class="text-center">No processes available</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>

        <!-- Back Button -->
        <div class="d-grid mt-4">
            <a href="${pageContext.request.contextPath}/ActivityMonitor.jsp" class="btn btn-secondary btn-lg">Back to Monitor</a>
        </div>
    </div>

    <script>
        Chart.register(ChartDataLabels);

        // Ensure valid data for the charts and handle "N/A" or null
        const cpuUsage = "${cpuUsage}" === "N/A" || "${cpuUsage}" === "" || "${cpuUsage}" == null ? 0 : parseFloat("${cpuUsage}") || 0;
        const cpuAvailable = 100 - cpuUsage;
        const heapMemoryUsed = parseFloat("${heapMemoryUsed}") || 0;
        const heapMemoryMax = parseFloat("${heapMemoryMax}") || 1; // Avoid division by zero
        const heapMemoryAvailable = parseFloat("${heapMemoryAvailable}") || 0;
        const nonHeapMemoryUsed = parseFloat("${nonHeapMemoryUsed}") || 0;
        const nonHeapMemoryMax = parseFloat("${nonHeapMemoryMax}") || 1; // Avoid division by zero
        const nonHeapMemoryAvailable = parseFloat("${nonHeapMemoryAvailable}") || 0;
        const physicalMemoryUsed = parseFloat("${inUsePhysicalMemory}") || 0;
        const physicalMemoryMax = parseFloat("${totalPhysicalMemory}") || 1; // Avoid division by zero
        const physicalMemoryAvailable = parseFloat("${availablePhysicalMemory}") || 0;

        // Calculate percentages with fallback for "N/A" or invalid data
        const cpuUsedPercent = cpuUsage;
        const cpuAvailablePercent = 100 - cpuUsedPercent;
        const heapUsedPercent = (heapMemoryUsed / heapMemoryMax * 100) || 0;
        const heapAvailablePercent = 100 - heapUsedPercent;
        const nonHeapUsedPercent = (nonHeapMemoryUsed / nonHeapMemoryMax * 100) || 0;
        const nonHeapAvailablePercent = 100 - nonHeapUsedPercent;
        const physicalUsedPercent = (physicalMemoryUsed / physicalMemoryMax * 100) || 0;
        const physicalAvailablePercent = 100 - physicalUsedPercent;

        // Create pie charts with error handling
        const createPieChart = (ctxId, usedPercent, availablePercent, label) => {
            const ctx = document.getElementById(ctxId);
            if (!ctx) {
                console.error(`Canvas element ${ctxId} not found`);
                return;
            }
            try {
                new Chart(ctx.getContext('2d'), {
                    type: 'pie',
                    data: {
                        labels: ['Used', 'Available'],
                        datasets: [{
                            data: [usedPercent, availablePercent],
                            backgroundColor: ['rgba(75, 192, 192, 0.6)', 'rgba(255, 206, 86, 0.6)'],
                            borderColor: ['rgba(75, 192, 192, 1)', 'rgba(255, 206, 86, 1)'],
                            borderWidth: 1
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                position: 'top'
                            },
                            tooltip: {
                                mode: 'index',
                                intersect: false,
                                callbacks: {
                                    label: function(context) {
                                        let label = context.label || '';
                                        if (label) label += ': ';
                                        label += context.parsed.toFixed(1) + '%';
                                        return label;
                                    }
                                }
                            },
                            datalabels: {
                                color: '#fff',
                                font: {
                                    weight: 'bold',
                                    size: 12
                                },
                                formatter: (value, ctx) => {
                                    const sum = ctx.chart.data.datasets[0].data.reduce((a, b) => a + b, 0);
                                    return ((value / sum) * 100).toFixed(1) + '%';
                                }
                            }
                        }
                    }
                });
            } catch (e) {
                console.error(`Error rendering ${label} pie chart:`, e);
            }
        };

        // Initialize pie charts with specific data
        createPieChart('cpuPieChart', cpuUsedPercent, cpuAvailablePercent, 'CPU');
        createPieChart('heapPieChart', heapUsedPercent, heapAvailablePercent, 'Heap');
        createPieChart('nonHeapPieChart', nonHeapUsedPercent, nonHeapAvailablePercent, 'Non-Heap');
        createPieChart('physicalPieChart', physicalUsedPercent, physicalAvailablePercent, 'Physical');

        // Create bar chart for system metrics
        const createBarChart = () => {
            const ctx = document.getElementById('systemMetricsChart');
            if (!ctx) {
                console.error('Canvas element systemMetricsChart not found');
                return;
            }
            try {
                new Chart(ctx.getContext('2d'), {
                    type: 'bar',
                    data: {
                        labels: ['CPU Usage', 'Heap Memory', 'Non-Heap Memory', 'Physical Memory'],
                        datasets: [
                            {
                                label: 'Used',
                                data: [cpuUsedPercent, heapUsedPercent, nonHeapUsedPercent, physicalUsedPercent],
                                backgroundColor: 'rgba(75, 192, 192, 0.6)',
                                borderColor: 'rgba(75, 192, 192, 1)',
                                borderWidth: 1,
                                stack: 'Stack 0'
                            },
                            {
                                label: 'Available',
                                data: [cpuAvailablePercent, heapAvailablePercent, nonHeapAvailablePercent, physicalAvailablePercent],
                                backgroundColor: 'rgba(255, 206, 86, 0.6)',
                                borderColor: 'rgba(255, 206, 86, 1)',
                                borderWidth: 1,
                                stack: 'Stack 0'
                            }
                        ]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: {
                            legend: {
                                display: true,
                                position: 'top',
                                labels: {
                                    generateLabels: function(chart) {
                                        return chart.data.datasets.map((dataset, i) => ({
                                            text: dataset.label,
                                            fillStyle: dataset.backgroundColor,
                                            strokeStyle: dataset.borderColor,
                                            lineWidth: dataset.borderWidth,
                                            hidden: !chart.isDatasetVisible(i),
                                            datasetIndex: i
                                        }));
                                    }
                                }
                            },
                            tooltip: {
                                mode: 'index',
                                intersect: false,
                                callbacks: {
                                    label: function(context) {
                                        let label = context.dataset.label || '';
                                        if (label) label += ': ';
                                        label += context.parsed.y.toFixed(1) + '%';
                                        return label;
                                    }
                                }
                            },
                            datalabels: {
                                color: '#000',
                                font: {
                                    weight: 'bold',
                                    size: 12
                                },
                                formatter: (value, ctx) => {
                                    const dataset = ctx.chart.data.datasets[ctx.datasetIndex];
                                    const total = dataset.data.reduce((a, b) => a + b, 0);
                                    return value === 0 ? '' : value.toFixed(1) + '%';
                                },
                                anchor: 'end',
                                align: 'top'
                            }
                        },
                        scales: {
                            y: {
                                beginAtZero: true,
                                max: 100,
                                stacked: true,
                                title: {
                                    display: true,
                                    text: 'Percentage (%)',
                                    font: { size: 14 }
                                },
                                ticks: {
                                    callback: function(value) {
                                        return value + '%';
                                    }
                                }
                            },
                            x: {
                                stacked: true,
                                title: {
                                    display: true,
                                    text: 'Metrics',
                                    font: { size: 14 }
                                }
                            }
                        },
                        onHover: (event, chartElement) => {
                            event.native.target.style.cursor = chartElement[0] ? 'pointer' : 'default';
                        }
                    }
                });
            } catch (e) {
                console.error('Error rendering bar chart:', e);
            }
        };

        // Initialize bar chart
        createBarChart();
    </script>
</body>
</html>