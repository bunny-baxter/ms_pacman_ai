import random
import socket
import subprocess

HOST = "127.0.0.1"
PORT = 7000

t = 0

def receive_and_send(connection):
    data = connection.recv(1024)
    for message in str(data, encoding = "utf-8").splitlines():
        if not message:
            continue
        print(message)
    direction = random.choice(["up", "down", "left", "right"])
    connection.sendall(f"joypad {direction}\n".encode())

with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
    s.bind((HOST, PORT))
    s.listen()

    # TODO: Probably don't need fceux's stdout, find a way to supress it.
    fceux_process = subprocess.Popen("./fceux.sh &", shell = True)
    fceux_process.communicate()

    connection, _address = s.accept()
    with connection:
        while True:
            try:
                receive_and_send(connection)
            except (ConnectionResetError, BrokenPipeError):
                print("Connection was reset (fceux probably closed). Exiting...")
                break
