extends Control

func _ready():
	$ver.text = ProjectSettings.get_setting("application/config/version")
	$container/settings/res/slider.value = Config.res
	$container/settings/res_scale/slider.value = Config.res_scale
	Config.apply_config()

func _on_bot_count_changed(value):
	$container/host/bot_count/value.text = str(value)
	$container/click.play()

func _on_max_score_changed(value):
	$container/host/max_score/value.text = str(value)
	$container/click.play()

func _on_host_pressed():
	Game.reload()
	Net.reset()
	$container/host/buttons/host.disabled = true
	$container/connect/buttons/connect.disabled = true
	yield(get_tree().create_timer(1.0), "timeout")
	Game.spawn_map(0)
	Game.spawn_gobot("1", 0)
	Net.bot_count = $container/host/bot_count/slider.value
	for i in Net.bot_count:
		Game.spawn_gobot("bot" + str(i), 2)
	visible = false
	$drone.stop()
	Net.create_server()

func _on_connect_pressed():
	$container/connect/buttons/connect.disabled = true
	Game.reload()
	Net.reset()
	yield(get_tree().create_timer(1.0), "timeout")
	Net.create_client($container/connect/ip/edit.text)

func _on_message_ok_pressed():
	$message.visible = false

func show_message(text : String):
	$message.visible = true
	$message/container/text.text = text

func _on_main_host_pressed():
	$container/main.visible = false
	$container/host.visible = true

func _on_main_connect_pressed():
	$container/main.visible = false
	$container/connect.visible = true

func _on_main_quit_pressed():
	get_tree().quit()

func _on_host_back_pressed():
	$container/host.visible = false
	$container/main.visible = true

func _on_connect_back_pressed():
	$container/connect.visible = false
	$container/main.visible = true

# Settings
func _on_settings_pressed():
	$container/main.visible = false
	$container/settings.visible = true

func _on_settings_save_pressed():
	Config.save_config()
	Config.apply_config()

func _on_settings_back_pressed():
	$container/main.visible = true
	$container/settings.visible = false

func _on_rs_value_changed(value):
	$container/settings/res_scale/value.text = str(value)
	Config.res_scale = value

# Resolution
func _on_res_value_changed(value):
	$container/settings/res/value.text = str(Config.RESOLUTIONS[value].x) + "x" + str(Config.RESOLUTIONS[value].y)
	Config.res = value


func _on_knockback_value_changed(value):
	Game.knockback = value


func _on_cooldown_value_changed(value):
	Game.cooldown = value
