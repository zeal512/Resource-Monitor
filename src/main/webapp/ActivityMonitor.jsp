<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Activity Monitor</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Custom CSS for additional styling -->
    <style>
        body {
            background-color: #f8f9fa;
        }
        .container {
            margin-top: 50px;
        }
        .card {
            box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
            border-radius: 10px;
        }
        .btn-primary {
            transition: transform 0.2s;
        }
        .btn-primary:hover {
            transform: scale(1.05);
        }
    </style>
    <script type="text/javascript">
        function setOS() {
            var userOS = navigator.userAgent || navigator.vendor || window.opera;
            var osField = document.getElementById("os");
            if (/Mac/.test(userOS)) {
                osField.value = "Mac OS";
            } else if (/Win/.test(userOS)) {
                osField.value = "Windows";
            } else {
                osField.value = "Unknown";
            }
        }
    </script>
</head>
<body onload="setOS()">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card p-4">
                    <h1 class="text-center mb-4">Activity Monitor</h1>
                    <form action="${pageContext.request.contextPath}/activity" method="post">
                        <input type="hidden" id="os" name="os" value="">
                        <div class="d-grid">
                            <button type="submit" class="btn btn-primary btn-lg">Launch Monitor</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <!-- Bootstrap JS and Popper.js -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>