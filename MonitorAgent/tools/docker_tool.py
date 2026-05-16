import docker

client = docker.from_env()

def check_docker():
    try:
        containers = client.containers.list(all=True)

        result = []

        for c in containers:
            result.append({
                "name": c.name,
                "status": c.status
            })

        return result

    except Exception as e:
        return {"error": str(e)}