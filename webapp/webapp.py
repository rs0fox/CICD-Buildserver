from flask import Flask, send_file
import boto3

app = Flask(__name__)

@app.route('/download')
def download():
    s3 = boto3.client('s3')
    s3.download_file('yourbucket', 'game', 'game')
    return send_file('game', as_attachment=True)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
