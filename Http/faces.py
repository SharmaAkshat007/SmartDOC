from google.cloud import vision
import io
from PIL import Image

def cropped(path, vertex):
    print(vertex)

    top_left = vertex[0]
    bottom_right = vertex[2]

    image = Image.open(path)

    cropped_image = image.crop((top_left[0], top_left[1], bottom_right[0], bottom_right[1]))


    # cropped_image.show()

    return cropped_image

def detect_faces(path):

    client = vision.ImageAnnotatorClient()

    with io.open(path, 'rb') as image_file:
        content = image_file.read()

    image = vision.Image(content=content)

    response = client.face_detection(image=image)
    faces = response.face_annotations

    # print(faces)

    vtx = [ (v.x, v.y) for face in faces for v in face.bounding_poly.vertices]
    print(vtx)

    print('number of faces', len(faces))

    cropped_images = [cropped(path, vtx[i:i+4]) for i in range(0, len(vtx), 4)]



    # vertices = ([(vertex.x, vertex.y) for vertex in faces[0].bounding_poly.vertices])

    # print(vertices)

    # top_left = vertices[0]
    # bottom_right = vertices[2]

    # image = Image.open(path)

    # cropped_image = image.crop((top_left[0], top_left[1], bottom_right[0], bottom_right[1]))


    # cropped_image.show()

    if response.error.message:
        raise Exception(
            '{}\nFor more info on error messages, check: '
            'https://cloud.google.com/apis/design/errors'.format(
                response.error.message))


    return cropped_images
    