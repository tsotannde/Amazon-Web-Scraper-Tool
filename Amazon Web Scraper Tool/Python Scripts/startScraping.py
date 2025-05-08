from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import random
import time

def print_reviews(review_blocks):
    for i, block in enumerate(review_blocks):
        try:
            title = block.find_element(By.CSS_SELECTOR, "[data-hook='review-title']").text
        except:
            title = "N/A"

        try:
            body = block.find_element(By.CSS_SELECTOR, "[data-hook='review-body']").text
        except:
            body = "N/A"

        try:
            rating = block.find_element(By.CSS_SELECTOR, "i[data-hook='review-star-rating'] span").get_attribute("textContent").strip()
        except:
            rating = "N/A"
            
        try:
            date = block.find_element(By.CSS_SELECTOR, "[data-hook='review-date']").text
        except:
            date = "N/A"

        print(f"\n⭐️ Review {i + 1}")
        print(f"Title: {title}")
        print(f"Rating is: {rating}")
        print(f"Date: {date}")
        print(f"Body: {body}")
        
        
def wait_for_reviews_to_load(driver):
    WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "cm_cr-review_list")))

def initiateScraping(asin, driver):
    print(f"-----------Inside the StartScraping.py-----------")
    print(f"ASIN: {asin}", flush=True)
    
    print("✅ Waiting for the Review Section to Load")
    wait_for_reviews_to_load(driver)
    print("✅ Review section is loaded!")
    
    while True:
        # Wait randomly between 3 to 5 seconds
        wait_time = random.uniform(3, 5) #Generates a random floating-point number between 3 and 5 seconds.
        print(f"🕒 Waiting for {wait_time:.2f} seconds before moving to next page...", flush=True)
        time.sleep(wait_time) #Pauses the Script for 3-5 Seconds. Allow for the Amazon Page to properly load
        
        try: #Lets try something out
        
            #TODO:- Process the Reviews Here
            review_blocks = driver.find_elements(By.CSS_SELECTOR, "#cm_cr-review_list [data-hook='review']")
            print_reviews(review_blocks)



            #Waits up to find seconds for the nextbutton to appear
            next_button = WebDriverWait(driver, 5).until(EC.element_to_be_clickable((By.CSS_SELECTOR, "li.a-last a")))
            print("➡️ Moving to next page...", flush=True)
            
            #Bring the Next Button into View
            driver.execute_script("arguments[0].scrollIntoView();", next_button)
            time.sleep(2) #LEts wait 2 seconds before clicking the next button
            driver.execute_script("arguments[0].click();", next_button) #Were good. Lets click the next button

            # Wait for the new review page to load
            WebDriverWait(driver, 10).until(EC.presence_of_element_located((By.ID, "cm_cr-review_list")))
            print("✅ New review page loaded!")

        except Exception:
            print("🏁 This is the last review page.", flush=True)
            print("📢📢📢 SCRAPING_COMPLETE_FLAG 📢📢📢", flush=True)
            break
