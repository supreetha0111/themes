<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>OTP Verification</title>
  <style>
    /* General reset */
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: Arial, sans-serif;
      background-color: #f5f5f5;
      color: #333;
    }

    .container {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: space-between;
      min-height: 100vh;
    }

    .header {
      width: 100%;
      background-color: #40A333;
      padding: 31px 20px;
      color: white;
      text-align: left;
      font-size: 1.2rem;
    }

    .logo {
        font-size: 22px;
        font-weight: 400;
        line-height: 1.2em;
        letter-spacing: 1.2px;
        font-family: Open Sans, Helvetica, Arial, sans-serif;
        text-align: left;
    }

    #logo {
      vertical-align: middle;
      margin-right: 5px;
    }

    .otp-background {
      width: 75%;
      display: flex;
      flex-direction: row;
      align-items: center;
      background: url(${url.resourcesPath}/img/Vector.png);
      background-size: contain;
      height: 75vh;
    }

    .otp-container {
      background: white;
      border-radius: 8px;
      padding: 20px;
      text-align: center;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
      max-width: 400px;
      margin: 20px auto;
    }

    .otp-container h2 {
      margin-bottom: 10px;
      font-size: 1.5rem;
    }

    .otp-container p {
      font-size: 0.9rem;
      color: #666;
      margin-bottom: 20px;
    }

    .otp-inputs {
      display: flex;
      justify-content: center;
      gap: 10px;
      margin-bottom: 20px;
    }

    .otp-box {
      width: 50px;
      height: 50px;
      text-align: center;
      font-size: 1.2rem;
      border: 1px solid #ccc;
      border-radius: 4px;
      outline: none;
    }

    .otp-box:focus {
      border-color: #40A333;
      box-shadow: 0 0 4px #40A333;
    }

    .otp-box.error {
      border-color: #b62940;
      box-shadow: 0 0 4px #b62940;
    }

    #verify-button {
      background-color: #40A333;
      color: white;
      border: none;
      padding: 10px 0;
      border-radius: 4px;
      cursor: pointer;
      font-size: 1rem;
      width: 100%;
    }

    #resend-link {
      display: block;
      margin-top: 20px;
      color: #40A333;
      text-decoration: none;
      width: 100%;
      text-align: center;
      cursor: pointer;
    }

    #response-message {
      margin-top: 20px;
    }

    .footer {
      font-size: 12px;
      margin-bottom: 10px;
      width: 100%;
      padding: 10px;
      color: #000000;
    }

    @media (max-width: 768px) {
        .otp-box {
            width: 35px;
            height: 35px;
            font-size: 1rem; /* Adjust font size for smaller screens */
        }
    }
  </style>
</head>
<body>
  <div class="container">
    <header class="header">
      <div class="logo">
        <img id="logo" src="${url.resourcesPath}/img/logo.png" alt="Logo"> BuilMirai
      </div>
    </header>
    <div class="otp-background">
      <div class="otp-container">
        <h2>OTP Verification</h2>
        <p>
          Enter the six-digit code sent to your registered email address, 
          <strong>
            <#if user?? && user.email??>
                <#assign parts = user.email?split("@")>
                <#assign maskedLocal = 
                    parts[0]?length > 2 
                    ? parts[0]?substring(0, 2) + "******" 
                    : "******">
                ${maskedLocal}@${parts[1]}
            </#if>
          </strong>
        </p>
        <form id="bsbu-login-otp-form" action="${url.loginAction}" method="post">
          <div class="otp-inputs">
            <input type="text" maxlength="1" class="otp-box" data-index="0">
            <input type="text" maxlength="1" class="otp-box" data-index="1">
            <input type="text" maxlength="1" class="otp-box" data-index="2">
            <input type="text" maxlength="1" class="otp-box" data-index="3">
            <input type="text" maxlength="1" class="otp-box" data-index="4">
            <input type="text" maxlength="1" class="otp-box" data-index="5">
          </div>
          <input type="hidden" name="client_id" value="${client.clientId}">
          <input type="hidden" id="emailOtp" name="emailOtp" maxlength="6">
          <button id="verify-button" type="submit">Verify</button>
        </form>
        <form id="bsbu-login-resend-otp-form" action="${url.loginAction}" method="post">
          <input type="hidden" name="action" value="resend" />
          <a id="resend-link">Resend OTP?</a>
        </form>
        <div id="response-message">
          ${displayMessage}
        </div>
      </div>
    </div>
    <footer class="footer">
      Sample Disclaimer: Use of this site is subject to our Terms of Use.
    </footer>
  </div>
  <script>
    document.addEventListener("DOMContentLoaded", function () {
      const otpInputs = document.querySelectorAll(".otp-box");
      const emailOtp = document.getElementById("emailOtp");
      const form = document.getElementById("bsbu-login-otp-form");

      otpInputs.forEach((input, index) => {
        input.addEventListener("input", () => {
          if (input.value.length === 1) {
            const nextInput = otpInputs[index + 1];
            if (nextInput) nextInput.focus();
          }
        });

        input.addEventListener("keydown", (e) => {
          if (e.key === "Backspace" && !input.value) {
            const prevInput = otpInputs[index - 1];
            if (prevInput) prevInput.focus();
          }
        });
      });

      form.addEventListener("submit", (event) => {
        event.preventDefault();
        const otpValue = Array.from(otpInputs).map((input) => input.value).join("");
        if (otpValue.length === 6) {
          emailOtp.value = otpValue;
          form.submit();
        } else {
          otpInputs.forEach((input) => input.classList.add("error"));
        }
      });

      document.getElementById("resend-link").addEventListener("click", (event) => { 
        event.preventDefault();
        document.getElementById("bsbu-login-resend-otp-form").submit();
      })
    });
  </script>
</body>
</html>
