import docker
import sys
import subprocess

class DockerUtils(object):

    def get_logs_container(self, name_container, path_file):
        client = docker.from_env()
        for container in client.containers.list():
            if "rulesprocessor" in container.name or "mongoinjector" in container.name:
                my_file = open(path_file + "/" + container.name + ".txt", "w")
                my_file.write(container.logs())
                subprocess.check_output('tar -czvf '+container.name+'.tar.gz ' +container.name+'.txt'+' ',shell=True)

if __name__ == '__main__':
    name_container=sys.argv[1]
    d = DockerUtils()
    d.get_logs_container(name_container, "/tmp")
