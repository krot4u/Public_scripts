<?php
if ($_SERVER["REQUEST_METHOD"] == "POST") {
    // Get the input value from the form
    $inputValue = $_POST["inputField"];

    // Validate or sanitize the input if needed

    // Run the Bash script with the input as an argument
    $output = shell_exec("bash /usr/local/sbin/sendLogs.sh" . escapeshellarg($inputValue));

    // Display the result or handle it as needed
    echo "<p>Thank You!</p>";
}
?>