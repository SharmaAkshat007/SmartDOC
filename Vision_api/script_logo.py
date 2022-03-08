from google.cloud import vision
import io

def detect_logos(path):
    
    client = vision.ImageAnnotatorClient()

    with io.open(path, 'rb') as image_file:
        content = image_file.read()

    image = vision.Image(content=content)

    response = client.logo_detection(image=image)
    logos = response.logo_annotations
    print('Logos:')

    for logo in logos:
        print(logo.description)

    if response.error.message:
        raise Exception(
            '{}\nFor more info on error messages, check: '
            'https://cloud.google.com/apis/design/errors'.format(
                response.error.message))

if __name__ == "__main__":
    path = r"C:\Users\Akshat Sharma\Desktop\WhatsApp Image 2022-03-08 at 5.28.39 PM.jpeg"
    detect_logos(path)