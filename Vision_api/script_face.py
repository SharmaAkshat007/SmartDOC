from google.cloud import vision
import io
from PIL import Image

def detect_faces(path):

    client = vision.ImageAnnotatorClient()

    with io.open(path, 'rb') as image_file:
        content = image_file.read()

    image = vision.Image(content=content)

    response = client.face_detection(image=image)
    faces = response.face_annotations

    vertices = ([(vertex.x, vertex.y) for vertex in faces[0].bounding_poly.vertices])

    print(vertices)

    top_left = vertices[0]

    top_right = vertices[1]

    bottom_right = vertices[2]
    
    bottom_left = vertices[3]

    image = Image.open(path)

    cropped_image = image.crop((top_left[0], top_left[1], bottom_right[0], bottom_right[1]))


    cropped_image.show()

    if response.error.message:
        raise Exception(
            '{}\nFor more info on error messages, check: '
            'https://cloud.google.com/apis/design/errors'.format(
                response.error.message))

if __name__ == "__main__":
    path = r"C:\Users\Akshat Sharma\Desktop\IMG_0592.jpg"
    detect_faces(path)