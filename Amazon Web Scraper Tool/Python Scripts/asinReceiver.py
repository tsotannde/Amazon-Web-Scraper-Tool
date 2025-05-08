from setupChrome import launch_chrome
import sys

#Receives an ASIN (as a CLI argument)
def get_asin():
    if len(sys.argv) < 2:
        print("⚠️ Please provide an ASIN as an argument!")
        sys.exit(1)
    return sys.argv[1]

#Main Function
def main():
    print("-----------Inside the AsinReceiver.py-----------")
    asin = get_asin()
    print("✅ Received ASIN from ViewController.")
    print(f"📦 ASIN: {asin}")

    driver = launch_chrome(asin)  # ✅ pass asin here
    
if __name__ == "__main__":
    main()
