import subprocess

def check_nginx():
    try:
        status = subprocess.check_output(
            ["systemctl", "is-active", "nginx"],
            text=True
        ).strip()

        return {
            "nginx_status": status
        }

    except Exception as e:
        return {
            "error": str(e)
        }