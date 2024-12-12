import random
import string

# Generate a random 8-character string with lowercase letters
random_string = ''.join(random.choices(string.ascii_lowercase, k=8))

print(random_string)
