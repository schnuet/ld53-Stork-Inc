extends Panel

func show_now():
	show();
	
	$DayEnd.show();
	await get_tree().create_timer(1.0).timeout
	
	update_delivered_babies_label();
	await get_tree().create_timer(1.0).timeout
	
	$DayEndPopup/DayEnd/Babies/BabyBonus.show();
	$DayEndPopup/DayEnd/Babies/BabyBonus/Label.text = "+" + str(Game.get_baby_bonus());
	
	await get_tree().create_timer(1.0).timeout
	
	update_coins_made_label();
	await get_tree().create_timer(1.0).timeout

	update_employee_costs_label();
	await get_tree().create_timer(1.0).timeout

	update_total_of_day_label();
	await get_tree().create_timer(1.0).timeout
	

func update_delivered_babies_label():
	$DayEndPopup/DayEnd/Babies.show();
	$DayEndPopup/DayEnd/Babies/BabiesDeliveredResult.text = str(Game.babies_delivered_today);

	
func update_coins_made_label():
	$DayEndPopup/DayEnd/EarnedToday.show();
	$DayEndPopup/DayEnd/EarnedToday/result.text = str(Game.coins_made_today);

func update_employee_costs_label():
	$DayEndPopup/DayEnd/Costs.show();
	$DayEndPopup/DayEnd/Costs/EmployeeCostsResult.text = str(-Game.get_employee_costs());

func update_total_of_day_label():
	$DayEndPopup/DayEnd/Total.show();
	$DayEndPopup/DayEnd/Total/result.text = str(Game.total_gain_today);

