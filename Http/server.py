from fileinput import filename
from faces import detect_faces
import base64
from io import BytesIO
from crypt import methods
import os
from time import time
from flask import Flask, flash, request, redirect, url_for, jsonify
from werkzeug.utils import secure_filename
from werkzeug.exceptions import HTTPException
import subprocess

UPLOAD_FOLDER = 'temp/'
ALLOWED_EXTENSIONS = {'jpg', 'jpeg'}

app = Flask(__name__)
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER

def to_base64(image):
    buffered = BytesIO()
    image.save(buffered, format="JPEG")
    img_str = base64.b64encode(buffered.getvalue())
    return str(img_str)

def allowed_file(filename):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

def decode_b64(b64):
    if b64 == '':
        # resp = jsonify({'status': 400, 'message' : 'No file submitted'})
        # resp.status_code = 400
        return None
    
    # or, more concisely using with statement
    filename = secure_filename(str(int(1000*time()))+'.jpg')
    with open(os.path.join(app.config['UPLOAD_FOLDER'], filename), "wb") as fh:
        fh.write(base64.b64decode(b64))

    return filename

@app.route('/v1/extractDetails', methods=['POST'])
def extract_details():
    if request.method == 'POST':
        # check if the post request has the file part
        if 'file' not in request.files:
            resp = jsonify({'message' : 'No file part in the request'})
            resp.status_code = 400
            return resp
        file = request.files['file']
        # If the user does not select a file, the browser submits an
        # empty file without a filename.
        if file.filename == '':
            resp = jsonify({'status': 400, 'message' : 'No file submitted'})
            resp.status_code = 400
            return resp
        if file and allowed_file(file.filename):
            filename = secure_filename(str(int(1000*time()))+file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            # run readability cmd
            # return redirect(url_for('download_file', name=filename))
            # stdout = subprocess.run(['../Readability/predict', '--docker-image', 'nima-cpu', '--base-model-name', 'MobileNet', '--weights-file', os.path.join(os.getcwd(), '..', 'Readability', 'models', 'MobileNet', 'weights_mobilenet_technical_0.11.hdf5'), '--image-source', os.path.join(os.getcwd(), app.config['UPLOAD_FOLDER'], filename)], capture_output=True)
            # print('stdout:', stdout.stdout)
            # output = str(stdout.stdout)
            # output = output.split('\\n')
            # print(output)
            # output = [line.strip() for line in output]
            # print(output)
            # acc = float(str(output[4]).split()[-1])
            faces = detect_faces(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            b64_faces = [to_base64(face) for face in faces]
            resp = jsonify(
                {
                    'status': 200,
                    'verified': True,
                    'data': {
                        'num_faces': len(faces),
                        'faces' : b64_faces,
                    }
                }
            )
            resp.status_code = 200
            os.remove(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            return resp



@app.route('/v1/findReadability_b64', methods=['POST'])
def upload_file_b64():
    if request.method == 'POST':
        print(request.json['image'])
        # check if the post request has the file part
        if 'image' not in request.json:
            resp = jsonify({'message' : 'No image in the request'})
            resp.status_code = 400
            return resp
        b64 = request.json['image']
        # If the user does not select a file, the browser submits an
        # empty file without a filename.
        if b64 == '':
            resp = jsonify({'status': 400, 'message' : 'No file submitted'})
            resp.status_code = 400
            return resp
        
        # or, more concisely using with statement
        filename = secure_filename(str(int(1000*time()))+'.jpg')
        with open(os.path.join(app.config['UPLOAD_FOLDER'], filename), "wb") as fh:
            fh.write(base64.b64decode(b64))

        stdout = subprocess.run(['../Readability/predict', '--docker-image', 'nima-cpu', '--base-model-name', 'MobileNet', '--weights-file', os.path.join(os.getcwd(), '..', 'Readability', 'models', 'MobileNet', 'weights_mobilenet_technical_0.11.hdf5'), '--image-source', os.path.join(os.getcwd(), app.config['UPLOAD_FOLDER'], filename)], capture_output=True)
        # print('stdout:', stdout.stdout)
        output = str(stdout.stdout)
        output = output.split('\\n')
        # print(output)
        output = [line.strip() for line in output]
        # print(output)
        acc = float(str(output[4]).split()[-1])
        resp = jsonify(
            {
                'status': 200,
                'score': acc,
            }
        )
        resp.status_code = 200
        os.remove(os.path.join(app.config['UPLOAD_FOLDER'], filename))
        return resp



@app.route('/v1/findReadability', methods=['POST'])
def upload_file():
    if request.method == 'POST':
        # check if the post request has the file part
        if 'file' not in request.files:
            resp = jsonify({'message' : 'No file part in the request'})
            resp.status_code = 400
            return resp
        file = request.files['file']
        # If the user does not select a file, the browser submits an
        # empty file without a filename.
        if file.filename == '':
            resp = jsonify({'status': 400, 'message' : 'No file submitted'})
            resp.status_code = 400
            return resp
        if file and allowed_file(file.filename):
            filename = secure_filename(str(int(1000*time()))+file.filename)
            file.save(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            # run readability cmd
            # return redirect(url_for('download_file', name=filename))
            stdout = subprocess.run(['../Readability/predict', '--docker-image', 'nima-cpu', '--base-model-name', 'MobileNet', '--weights-file', os.path.join(os.getcwd(), '..', 'Readability', 'models', 'MobileNet', 'weights_mobilenet_technical_0.11.hdf5'), '--image-source', os.path.join(os.getcwd(), app.config['UPLOAD_FOLDER'], filename)], capture_output=True)
            # print('stdout:', stdout.stdout)
            output = str(stdout.stdout)
            output = output.split('\\n')
            # print(output)
            output = [line.strip() for line in output]
            # print(output)
            acc = float(str(output[4]).split()[-1])
            resp = jsonify(
                {
                    'status': 200,
                    'score': acc,
                }
            )
            resp.status_code = 200
            os.remove(os.path.join(app.config['UPLOAD_FOLDER'], filename))
            return resp


@app.route('/')
def index():
    return {
        "status": 200,
        "message": "You are using DIQA++ REST APIs",
    }


@app.errorhandler(HTTPException)
def handle_exception(e):
    """Return JSON instead of HTML for HTTP errors."""
    # start with the correct headers and status code from the error
    # response = e.get_response()
    # replace the body with JSON
    response = jsonify({
        "code": e.code,
        "name": e.name,
        "description": e.description,
    })
    response.status = e.code
    return response


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)