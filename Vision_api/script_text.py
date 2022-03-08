from google.cloud import vision
import io

def detect_text(path):
    client = vision.ImageAnnotatorClient()

    with io.open(path, 'rb') as image_file:
        content = image_file.read()

    image = vision.Image(content=content)

    response = client.text_detection(image=image)
    texts = response.text_annotations
    
    infomation = texts[0].description.split("\n")

    aadhar_number = int()

    for info in infomation:
        ws = info.split(" ")
        ws = ''.join(ws)
        if ws.isnumeric() and len(ws) == 12:
            aadhar_number = int(ws)

    
    print(aadhar_number)
    if response.error.message:
        raise Exception(
            '{}\nFor more info on error messages, check: '
            'https://cloud.google.com/apis/design/errors'.format(
                response.error.message))

    return aadhar_number

if __name__ == "__main__":
    path = r"C:\Users\Akshat Sharma\Desktop\WhatsApp Image 2022-03-08 at 12.03.49 AM.jpeg"
    detect_text(path)