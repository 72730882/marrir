import base64
from io import BytesIO

from sqlalchemy import inspect
from sqlalchemy.orm.relationships import RelationshipProperty

def read_html_template(file_path):
    content = ''
    with open(file_path, 'r', encoding='utf-8') as file:
        for line in file:
            content += line
    return content


def generate_report(title: str, entity):
    # text_content = f"{title}\n\n"

    # attributes = [
    #     attr
    #     for attr in dir(entity)
    #     if not callable(getattr(entity, attr))
    #     and not attr.startswith("_")
    #     and not attr == "metadata"
    #     and not attr == "registry"
    # ]

    # for attribute in attributes:
    #     value = getattr(entity, attribute)
    #     text_content += f"{attribute.replace('_', ' ').title()}: {value}\n"

    # # Save the generated text content to a file
    # with open("generated_text.txt", "w", encoding="utf-8") as text_file:
    #     text_file.write(text_content)

    # return text_content
    html_content = read_html_template("C:\\Users\\Kaleb\\Desktop\\graduated_cv.html")

    attributes = [
        attr
        for attr in dir(entity)
        if not callable(getattr(entity, attr))
        and not attr.startswith("_")
        and not attr == "metadata"
        and not attr == "registry"
    ]

    # for attribute in attributes:
    #     value = getattr(entity, attribute)
    #     if isinstance(value, bytes):
    #         # Handle binary data (e.g., images)
    #         value = base64.b64encode(value).decode("utf-8")
    #         html_content += (
    #             f'<img src="data:image/png;base64,{value}" alt="{attribute}">'
    #         )
    #     else:
    #         if value:
    #             html_content += f"<p>{attribute.replace('_', ' ').title()}: {value}</p>"
    #         else:
    #             html_content += f"<p>{attribute.replace('_', ' ').title()}: </p>"

    # for relation in inspect(entity).mapper.relationships:
    #     if isinstance(relation, RelationshipProperty):
    #         related_model_instance = getattr(entity, relation.key, None)
    #         if related_model_instance:
    #             html_content += "<h2>{}</h2>".format(relation.key.capitalize())
    #             for related_column in inspect(related_model_instance).mapper.column_attrs:
    #                 related_column_name = related_column.key
    #                 related_column_value = getattr(related_model_instance, related_column_name, "")
    #                 html_content += f"<p>{related_column_name.capitalize()}: {related_column_value}</p>"

    # html_content += "</body></html>"
    # print(html_content)
    return html_content
