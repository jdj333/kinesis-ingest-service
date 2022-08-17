from flask import Flask
from flask import request
from multiprocessing import Process

class processClass:

    def __init__(self):
        p = Process(target=self.run, args=())
        p.daemon = True                       # Daemonize it
        p.start()                             # Start the execution

    def run(self):

         #
         # This might take several minutes to complete
         someHeavyFunction()

app = Flask(__name__)

@app.route('/start', methods=['POST'])
    try:
        begin = processClass()
    except:
        abort(500)

    return "Task is in progress"

def main():
    """
    Main entry point into program execution

    PARAMETERS: none
    """
    app.run(host='0.0.0.0',threaded=True)
