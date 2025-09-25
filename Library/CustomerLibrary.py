import requests
import random
import string


class CustomerLibrary:
    def get_random_users(self):
        response = requests.get("https://jsonplaceholder.typicode.com/users")

        users = response.json()
        for i in users:
            # extract first name and last name only
            titles = ["Mr.", "Mrs.", "Ms."]
            name_parts = i["name"].split()
            i["name"] = [name for name in name_parts if name not in titles]

            # generate random birthday, password, and stateAbbr
            i["birthday"] = self.get_random_birthday()
            i["iso_birthday"] = self.format_birthday(i["birthday"])
            i["password"] = self.generate_password()
            i["address"]["stateAbbr"] = (
                str(i["address"]["street"][0])
                + str(i["address"]["suite"][0])
                + str(i["address"]["city"][0])
            )

        return users

    def get_random_birthday(self):
        month = str(random.randint(1, 12)).zfill(2)
        day = str(random.randint(1, 28)).zfill(2)
        year = str(random.randint(1996, 2006))
        return f"{month}{day}{year}"

    def generate_password(self, length=8):
        chars = string.ascii_letters + string.digits + "!@#$%"
        return "".join(random.choice(chars) for _ in range(8))
    
    def format_birthday(self, birthday):
        return f"{birthday[-4:]}{birthday[:2]}{birthday[2:4]}"