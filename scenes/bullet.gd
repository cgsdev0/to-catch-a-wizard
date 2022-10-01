extends Sprite

export var velocity = Vector2(0, 0)

func _process(delta):
    move(delta)
    removeWhenOffScreen()

func move(delta):
    global_position += velocity * delta

func removeWhenOffScreen():
    pass
    # queue_free()
