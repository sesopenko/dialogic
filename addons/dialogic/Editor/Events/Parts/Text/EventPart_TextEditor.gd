tool
extends "res://addons/dialogic/Editor/Events/Parts/EventPart.gd"

# has an event_data variable that stores the current data!!!

## node references
onready var text_editor = $TextEdit


# used to connect the signals
func _ready():
	# signals
	text_editor.connect("text_changed", self, "_on_TextEditor_text_changed")
	text_editor.connect("focus_entered", self, "_on_TextEditor_focus_entered")
	
	# stylistig setup
	text_editor.syntax_highlighting = true
	text_editor.add_color_region('[', ']', get_color("axis_z_color", "Editor"))
	text_editor.set('custom_colors/number_color', get_color("font_color", "Editor"))
	text_editor.set('custom_colors/function_color', get_color("font_color", "Editor"))
	text_editor.set('custom_colors/member_variable_color', get_color("font_color", "Editor"))
	text_editor.set('custom_colors/symbol_color', get_color("font_color", "Editor"))


# called by the event block
func load_data(data:Dictionary):
	# First set the event_data
	.load_data(data)
	
	# Now update the ui nodes to display the data. 
	# in case this is a text event
	if data['event_id'] == 'dialogic_001':
		text_editor.text = event_data['text']
	# in case this is a question event
	elif data['event_id'] == 'dialogic_010':
		text_editor.text = event_data['question']
	# otherwise
	else:
		text_editor.text = event_data['text']
	
	# resize the text_editor to the correct size 
	_set_new_min_size()

# has to return the wanted preview, only useful for body parts
func get_preview():
	var max_preview_characters = 35
	var text = ''
	if event_data['event_id'] == 'dialogic_001':
		text = event_data['text']
	# in case this is a question event
	elif event_data['event_id'] == 'dialogic_010':
		text = event_data['question']
	# otherwise
	else:
		text = event_data['text']
	text = text.replace('\n', '[br]')
	var preview = text.substr(0, min(max_preview_characters, len(text)))
	if (len(text) > max_preview_characters):
		preview += "..."
	
	return preview

func _on_TextEditor_text_changed():
	# in case this is a text event
	if event_data['event_id'] == 'dialogic_001':
		event_data['text'] = text_editor.text
	# in case this is a question event
	elif event_data['event_id'] == 'dialogic_010':
		event_data['question'] = text_editor.text
	# otherwise
	else:
		event_data['text'] = text_editor.text
	_set_new_min_size()
	
	# informs the parent about the changes!
	data_changed()


func _set_new_min_size():
	# Reset
	text_editor.rect_min_size = Vector2(0,0)
	# Getting new sizes
	var extra_vertical = 1
	var longest_string = ''
	
	if text_editor.get_line_count() > 1:
		extra_vertical = 1.2
	
	text_editor.rect_min_size.y = get_font("normal_font").get_height() * ((text_editor.get_line_count() + 1) * extra_vertical)
	
	#for line in text_editor.get_line()
	text_editor.rect_min_size.x = get_font("normal_font").get_string_size(text_editor.get_line(0)).x + 50


func _on_TextEditor_focus_entered() -> void:
	if (Input.is_mouse_button_pressed(BUTTON_LEFT)):
		emit_signal("request_selection")


func _on_TextEdit_focus_exited():
	# Remove text selection to visually notify the user that the text will not 
	# be copied if they use a hotkey like CTRL + C 
	$TextEdit.deselect()
