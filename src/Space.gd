extends TextureRect

export(float) var density: = 0.005
export(float) var power_law: = 5.0

var rng: = RandomNumberGenerator.new()

func _ready() -> void:
    set_stretch_mode(STRETCH_TILE)

    var size: Vector2 = get_size()
    var width: int = int(size.x)
    var height: int = int(size.y)
    
    rng.randomize()

    var img: = Image.new()
    img.create(width, height, false, Image.FORMAT_RGB8)
    img.lock()
    img.fill(Color(0.0, 0.0, 0.0))
    var nstars = round(width * height * density)
    for _n in range(nstars):
        var x: = rng.randi_range(0, width - 1)
        var y: = rng.randi_range(0, height - 1)
        var flux: = pow(rng.randf(), power_law)
        img.lock()
        img.set_pixel(x, y, Color(flux, flux, flux))
    
    texture = ImageTexture.new()
    texture.create_from_image(img)
