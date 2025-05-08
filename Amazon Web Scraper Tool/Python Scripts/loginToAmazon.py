# loginToAmazon.py
from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import os

def login_only():
    print("-----------Launching Chrome for Manual Login-----------")

    # Define profile path
    script_dir = os.path.dirname(os.path.abspath(__file__))
    custom_profile_path = os.path.join(script_dir, "ChromeProfile")

    options = webdriver.ChromeOptions()
    options.add_argument(f"user-data-dir={custom_profile_path}")

    # Launch browser
    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)

    # Save Chrome PID to file for cleanup later
    pid_file_path = os.path.join(script_dir, "chrome_pid.txt")
    with open(pid_file_path, "w") as f:
        f.write(str(driver.service.process.pid))

    # Go to Amazon homepage
    driver.get("https://www.amazon.com")

    print("🔓 Please log into your Amazon account manually in the browser.")
    print("⏳ Leave this window open for as long as you need.")

    # Keep the window open indefinitely until user closes it
    input("✅ Press ENTER here in terminal when you're done logging in...\n")

    print("✅ Login complete. You can now run your scraper!")
    driver.quit()

if __name__ == "__main__":
    login_only()
