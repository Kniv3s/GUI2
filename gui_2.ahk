#SingleInstance, Force

Thread, interrupt, 0
SetKeyDelay, 100, 15

Target := "BlueStacks"
Times := [0, 30, 60, 90, 310, 2430, 3030, 3640, 4240]

;Thhese one will be reset by the gui on run and values in here dont matter
Running := 0
FoundChest := 0
Fighting := 0
GoldSetup := 0
Alt := 0
Type = 0
ItemGrey :=  0
ItemBlue := 0
ItemMagenta := 0
ItemRed := 0
LowMp := 0

;These variables set the default and thus values in here do matter
KapAttempts := 26
HealthPerc := 45
Message := "None"


Gui, Add, Button, vStatusButton gStatusToggle x020 w100, Play Pause
Gui, Add, Text, vStatusText xp+110 yp+5, Status Off
Gui, Add, Text, xp-110 yp+30, Smith Health Use
Gui, Add, Slider,vSmithSlider Range15-55 NoTicks ToolTip, %HealthPerc%
Gui, Add, Text,, Failed Captcha Attempts
Gui, Add, Edit, w50 0x100 ReadOnly vKapEdit, %KapAttempts%
Gui, Add, UpDown,-16 hp x+0 gWindowAction vKapUpDown Range0-96, %KapAttempts%
Gui, Add, CheckBox, gWindowAction vKapBox xp-50 yp+30, Brute Force Kaptcha
Gui, Add, CheckBox, gWindowAction vLowMpBox, Low MP Setup
Gui, Add, Tab3, gWindowAction vModeTab AltSubmit, Battle|Dragon|Idle
Gui, Tab, 1
Gui, Add, CheckBox, gWindowAction vAdsBox, Run ads
Gui, Add, CheckBox, gWindowAction vAltBox, Use Alter
Gui, Add, CheckBox, gWindowAction vGoldBox Checked, Gold Setup
Gui, Tab, 2
Gui, Add, Text,, Items to Keep
Gui, Add, CheckBox, gWindowAction vGreyBox, Grey
Gui, Add, CheckBox, gWindowAction vBlueBox xp+70 yp, Blue
Gui, Add, CheckBox, gWindowAction vMagentaBox xp-70 yp+20 Checked, Magenta
Gui, Add, CheckBox, gWindowAction vRedBox xp+70 yp Checked, Red
Gui, Tab, 3
Gui, Add, Text,, Nothing To See Here
Gui, Tab
Gui, Add, StatusBar, vMessageText xp yp+20, None

Gui, Show,, Grow Castle

GoSub, UpdateVars

return
Sendx(X, T := 100)
{
	if WinActive("BlueStacks")
	{
		Send, %X%
		Sleep, %T%
	}
}

UpdateText(Text)
{
	SB_SetText(Text)
	return
}

CheckPixel(X, Y, P)
{
	PixelGetColor, Out, X, Y
	return Out = P
}

ReplayLast:
{
	;Old logic
}
return

InfiniteTower:
{
	;Old logic
}
return

WindowAction:
{
	if (Running = 1)
	{
		if WinExist("BlueStacks")
			WinActivate
	}
	GoSub, UpdateVars
}
return

StatusToggle:
{
	if (Running = 0)
	{
		Running := 1
		Gui, Font, cGreen
		GuiControl, Font, StatusText
		GuiControl,, StatusText, Status On
		SetTimer, MainLoop, 100
		if WinExist("BlueStacks")
			WinActivate
	}
	else
	{
		Running := 0
		Gui, Font, cRed
		GuiControl, Font, StatusText
		GuiControl,, StatusText, Status Off
	}
	GoSub, UpdateVars
}
return

UpdateVars:
{
	Gui, Submit, NoHide
	Kap := KapBox
	Ads := AdsBox
	Alt := AltBox
	Type := ModeTab - 1
	ItemGrey := GreyBox
	ItemBlue := BlueBox
	ItemMagenta := MagentaBox
	ItemRed := RedBox
	LowMp := LowMpBox
	HealthPerc := SmithSlider
	KapAttempts := KapUpDown
	GoldSetup := GoldBox
	GuiControl,,SmithSubmit,%HealthPerc%
	t := (KapAttempts // 4) . ":" . (Mod(KapAttempts, 4) * 15)
	if (Mod(KapAttempts, 4) = 0)
	{
		t := t . 0
	}
	GuiControl,,KapEdit,%t%
}
return

MainLoop:
{
	if (Running = 0)
	{
		;SetTimer, MainLoop, Off
		return
	}
	if WinActive("BlueStacks")
	{
		Fighting := 0
		;check to see if we are on the main page
		PixelGetColor, Out, 455, 555
		While (Out = 0x98ADBA OR Out = 0x71797D) AND WinActive("BlueStacks") AND Fighting = 0 AND Running = 1
		{
			UpdateText("Main Loop Execution")
			FoundChest := 0
			if (Ads = 1)
			{
				GoSub, RunAds
			}
			;check for max gems
			if CheckPixel(424, 69, 0xF8CF55)
			{
				UpdateText("Spending Gems")
				Sendx("t", 5000)
			}
			;Check for cactus man
			Found = 0
			loop, 150
			{
				if CheckPixel(410, 330, 0x4E4EFF)
				{
					Found = 1
					if NOT CheckPixel(450, 210, 0x4499D5)
					{
						Sendx("w", 350)
					}
					break
				}
				sleep, 10
			}
			if (Found = 1)
			{
				break
			}
			if (GoldSetup = 1) AND (Type = 0)
			{
				if NOT CheckPixel(652, 406, 0x0EB1F8)
				{
					Sendx("e", 400)
				}
			}
			else if NOT CheckPixel(795, 395, 0x0BA671)
			{
				Sendx("q", 400)
			}
			if (Type = 0)
			{
				
				GoSub, RunBattle
				Fighting := 1
			}
			else if (Type = 1)
			{
				GoSub, DragonFarm
				Fighting := 1
			}
		}
		GoSub, KaptchaCheck
		While CheckPixel(60, 800, 0xEED064) AND WinActive("BlueStacks") AND Running = 1
		{
			if (Type != 1 AND FoundChest = 0)
			{
				GoSub, ChestFind
			}
			GoSub, HeroPowers
			if CheckPixel(1409, 815, 0x316780)
			{
				Sendx("0", 300)
			}
		}
		if (Type = 1)
		{
			sleep, 750
			GoSub, RelicProccess
		}
	}
	else
	{
		if WinActive("ahk_exe chrome.exe") AND Running = 1
		{
			GoSub, WindowAction
		}
	}
	SetTimer, MainLoop, 100
}
return

RunBattle:
{
	UpdateText("Next Battle")
	Fighting := 1
	FoundChest := 0
	if CheckPixel(455, 555, 0x495762)
	{
		Send, {Esc}
		Sleep, 100
		Send, {Esc}
		Sleep, 100
	}
	Sendx("0", 1000)
	if (Alt = 1)
	{ 
		if CheckPixel(140, 215, 0xFFBC54)
		{
			Sendx("z")
		}
	}
}
return

DragonFarm:
{
	UpdateText("Dragon Loop")
	Sendx("d", 500)
	While CheckPixel(953, 67, 0x8F9094)
	{
		Sendx("d", 300)
	}
}
return

KaptchaCheck:
{
	t := -1
	a := -1
	K_ := 1
	T := A_TickCount
	if ( ((A_Hour * 60) + A_Min) > (KapAttempts * 15) + 20 )
	{
		ret := (KapAttempts + (24 * 4)) * 15
	}
	else
	{
		ret := KapAttempts * 15
	}
	While CheckPixel(615, 755, 0x90C5E3) AND Running = 1
	{
		if NOT CheckPixel(955, 470, 0xDBDBDB)
		{
			if (Kap = 1)
			{
				ret_ := ((A_Hour * 60) + A_Min) + (Times[K_] // 60)
				msg := ret_ . ":" . ret . ":" . K_
				if (K_ = 1 OR (ret_ < ret) )
				{
					Sendx("k", 5000)
					Random, rand, 0, 4
					Switch rand
					{
					Case 0:
						Sendx("1", 200)
					Case 1:
						Sendx("2", 200)
					Case 2:
						Sendx("3", 200)
					Case 3:
						Sendx("4", 200)
					Case 4:
						Sendx("5", 200)
					}
					K_ := K_ + 1
					sleep, 3000
					msg := msg . ":X"
				}
				FileAppend, %msg%`n, KapLog.txt
			}
			else
			{
				if (a = -1)
				{
					a := 20
				}
				SoundBeep
				if (a = 0)
				{
					Kap := 1
					GuiControl,, KapBox, 1
				}
				a := a - 1
			}
		}
		if (Kap = 1) AND (K_ > 0)
		{
			text := "Kaptcha Checking "  . "tries left " . K_
		}
		else if (Kap = 1)
		{
			text := "Out of Kaptcha Attempts"
		}
		else
		{
			text := "Kaptcha Checking " . a . "s till brute force"
		}
		UpdateText(text)
		sleep, 1000
	}
}
return

HeroPowers:
{
	UpdateText("Hero Powers")
	arr_x := [340, 430, 530]
	arr_y := [100, 215, 325, 430]
	arr_in := ["6", "7", "-", "=", "y", "o", "p", "s", "f", "g"]
	x := 720 + Floor((1100-720) * (HealthPerc / 100))
	if (LowMp = 1) AND CheckPixel(345, 213, 0xFFBC54)
	{
		Sendx("j", 700)
	}
	UsedPower := 1
	While (UsedPower = 1)
	{
		UsedPower := 0
		loop, 10
		{
			if NOT CheckPixel(x, 60, 0x4C4CE8) AND CheckPixel(345, 100, 0xFFBC54)
			{
				Sendx("9")
			}
			x_ := Mod(A_Index + 1, 3) + 1
			y_ := ((A_Index + 1) // 3) + 1
			if CheckPixel(arr_x[x_], arr_y[y_], 0xFFBC54)
			{
				Sendx(arr_in[A_Index])
				UsedPower := 1
			}
		}
	}
	if CheckPixel(435, 100, 0xFFBC54)
	{
		Sendx("8", 200)
	}
}
return

ChestFind:
{
	if CheckPixel(815, 105, 0x000000)
	{
		Sendx("c", 800)
		FoundChest := 1
	}
}
return

RelicProccess:
{ 
	While CheckPixel(575, 660, 0x5A48EF)
	{
		PixelGetColor, Out, 675, 650
		if (ItemGrey = 0 and Out = 0xA6A385)
		{
			Sendx("m", 300)
		}
		else if (ItemBlue = 0 and Out = 0xEACD17)
		{
			Sendx("m", 300)
		}
		else if (ItemMagenta = 0 and Out = 0xD50FEC)
		{
			Sendx("m", 300)
		}
		else if (ItemRed = 0 and Out = 0x2E29E1)
		{
			Sendx("m", 300)
		}
		else
		{
			Sendx("i", 200)
		}
	}
}
return

RunAds:
{
	UpdateText("Running Ads")
	Sleep, 1000
	;search if an add offer exists
	if CheckPixel(836, 677, 0x495762)
	{
		Sendx("a")
		sleep, 10000
		PixelGetColor, Out, 455, 555
		While (Out != 0x98ADBA and Out != 0x71797D) and WinActive("BlueStacks")
		{
			Sendx("{Esc}")
			sleep, 5000
			if CheckPixel(50, 815, 0xE6E6E6) and CheckPixel(1464, 77, 0xFFFFFF)
			{
				Sendx("x")
			}
			PixelGetColor, Out, 455, 555
		}
	}
}
return

GuiClose:
	ExitApp
