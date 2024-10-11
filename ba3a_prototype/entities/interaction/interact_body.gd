extends StaticBody3D
class_name InteractBody

signal interacted

func interact():
	interacted.emit()
