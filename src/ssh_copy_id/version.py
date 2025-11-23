from pathlib import Path
import tomllib

def get_version():
    version = "unknown"
    # adopt path to your pyproject.toml
    pyproject_toml_file = Path(__file__).parent.parent.parent / "pyproject.toml"
    if pyproject_toml_file.exists() and pyproject_toml_file.is_file():
        with open(pyproject_toml_file, 'rb') as pyproject_toml:
            data = tomllib.load(pyproject_toml)
            # check project.version
            if "project" in data and "version" in data["project"]:
                version = data["project"]["version"]
    return version