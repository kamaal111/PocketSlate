from typing import Callable, TypeVar, Iterable

from PIL import Image


ListItemTypeVar = TypeVar("ListItemTypeVar")


WHITENESS_TRESHOLD = 200


def all_satisfy(
    items: Iterable[ListItemTypeVar], condition: Callable[[ListItemTypeVar], bool]
):
    for item in items:
        if not condition(item):
            return False

    return True


def replace_pixel_color(
    input_image: Image,
    callback: Callable[
        [tuple[int, int, int, int]],
        tuple[int, int, int, int],
    ],
):
    # Convert the image to RGBA mode (if it's not already)
    image = input_image.convert("RGBA")

    # Get the image data as a list of pixels
    data = image.getdata()

    # New list to store the modified pixel data
    new_data = []

    # Iterate through each pixel
    for pixel in data:
        new_data.append(callback(pixel))

    # Update the image with the modified pixel data
    image.putdata(new_data)
    return image


def make_background_transparent(input_image: Image):
    return replace_pixel_color(
        input_image,
        lambda pixel: (pixel[0], pixel[1], pixel[2], 0)
        if all_satisfy(pixel[:3], lambda color: color > WHITENESS_TRESHOLD)
        else pixel,
    )


if __name__ == "__main__":
    make_background_transparent(Image.open("Resources/raw-globe.png")).save(
        "Resources/globe.png", format="PNG"
    )
