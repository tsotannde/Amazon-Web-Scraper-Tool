from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
import os
import time
from selenium.webdriver.common.by import By
from startScraping import initiateScraping

    
def launch_chrome(asin):
    print(f"-----------Inside the SetupChrome.py-----------")
    print(f"Asin Passed to SetupChrome.py Script {asin}")
    
    # Define paths
    script_dir = os.path.dirname(os.path.abspath(__file__))
    custom_profile_path = os.path.join(script_dir, "ChromeProfile")
    cookies_file_path = os.path.join(script_dir, "cookies.pkl")
    
    
    #Setup WebDriver with Chrome user profile
    options = webdriver.ChromeOptions()
    
    
    options.add_argument(f"user-data-dir={custom_profile_path}")  # Store session data


    service = Service(ChromeDriverManager().install())
    driver = webdriver.Chrome(service=service, options=options)
    
        # Save Chrome PID to file for cleanup later
    pid_file_path = os.path.join(script_dir, "chrome_pid.txt")
    with open(pid_file_path, "w") as f:
        f.write(str(driver.service.process.pid))
        
    driver.get("https://www.amazon.com")
    
    
    #Lets Start doing the fun stuff
    # Navigate to the review page of the given ASIN
    review_url = f"https://www.amazon.com/product-reviews/{asin}/"
    print(f"🌐 Navigating to ASIN review page: {review_url}")
    
    driver.get(review_url)
    
    initiateScraping(asin, driver)
    


    
    

    
  


# Function to detect if the current page is a CAPTCHA page
def detect_captcha_page(driver):
    print("Detecting if Page is CAPTCHA or NOT")
    html = driver.page_source
    if "Enter the characters you see below" in html or "/errors/validateCaptcha" in html:
        print("🚨 This page is a CAPTCHA page.")
        return True
    print("✅ This page is NOT a CAPTCHA page.")
  
    return False

# Checking if User is logged in or not
#TODO :-
def detect_sign_in_status(driver):
    try:
        element = driver.find_element(By.ID, "nav-link-accountList-nav-line-1")
        text = element.text.strip().lower()
        if "sign in" in text:
            print("❌ User is NOT signed in.")
            print("⏳ Waiting 30 seconds for user to log in...")
            #time.sleep(20)
            print("⛔️ Still not signed in. Exiting program.")
            driver.quit()
            exit(1)
        else:
            print("✅ User IS signed in.")
            #time.sleep(20)
    except Exception as e:
        print(f"⚠️ Could not detect sign-in status: {e}")
        
        


