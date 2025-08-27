from json import dumps

from pydantic import BaseModel, Field
from typer import Argument, Typer, echo, run


class Spec(BaseModel):
    filename: str = Field(..., title='Part of the filename specific to these specs')
    title: str = Field(..., title='User readable name to create the link')
    openapi: dict


from webapp.main import app as fastapi_app  # noqa: E402

specs = [
    Spec(
        filename='backend-integration',
        title='Backend Integration - API',
        openapi=fastapi_app.openapi(),
    ),
]
# HOWTO: Don't touch the code below

typerapp = Typer()


def main(
    version_name: str = Argument(..., help='Code version name, e.g. git branch name'),
    local_output_dir: str = Argument(..., help='Path on disk where to put the generated files'),
    url: str = Argument(..., help='URL where the files will be accessible online'),
):
    for spec in specs:
        filename = f'{version_name}_{spec.filename}_openapi.json'
        output_file = f'{local_output_dir}/{filename}'

        with open(output_file, 'w') as json_file:
            json_file.write(dumps(spec.openapi))
            echo(f'[{spec.title}]({url}{filename})\r\n')


if __name__ == '__main__':
    run(main)
