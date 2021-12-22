package;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import Achievements;
import editors.MasterEditorMenu;

using StringTools;

class MainMenuState extends MusicBeatState
{ 
	public static var psychEngineVersion:String = '0.4'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	var iconJohn:FlxSprite;

	var menuItems:FlxTypedGroup<FlxSprite>;
	private var camGame:FlxCamera;
	private var camAchievement:FlxCamera;
	private var iconStory:FlxSprite;
	private var iconFreeplay:FlxSprite;
	private var iconAwards:FlxSprite;
	private var iconCredits:FlxSprite;
	private var iconOptions:FlxSprite;
	
	var optionShit:Array<String> = ['story_mode', 'freeplay', #if ACHIEVEMENTS_ALLOWED 'awards', #end 'credits', #if !switch #end 'options'];

	public static var firstStart:Bool = true;

	public static var finishedFunnyMove:Bool = false;

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	var camFollowPos:FlxObject;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();
		camAchievement = new FlxCamera();
		camAchievement.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camAchievement);
		FlxCamera.defaultCameras = [camGame];

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var yScroll:Float = Math.max(0.0 - (0.0 * (optionShit.length - 3)), 0.1);
		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, yScroll);
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = ClientPrefs.globalAntialiasing;
		add(bg);

		var blackMenu:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('blackMenu'));
		blackMenu.x += 45;
		blackMenu.y += -28;
		blackMenu.setGraphicSize(Std.int(blackMenu.width * 1.220));
		blackMenu.scrollFactor.set(0, yScroll);
		blackMenu.updateHitbox();
		blackMenu.antialiasing = ClientPrefs.globalAntialiasing;
		add(blackMenu);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollowPos = new FlxObject(0, 0, 1, 1);
		add(camFollow);
		add(camFollowPos);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, yScroll);
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = ClientPrefs.globalAntialiasing;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var offset:Float = 95 - (Math.max(optionShit.length, 4) - 4) * 80;
			var menuItem:FlxSprite = new FlxSprite(1, (i * 145)  + offset);
			menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 30);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 30);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			//menuItem.screenCenter(X);
			menuItem.x += 80;
			menuItems.add(menuItem);
			var scr:Float = (optionShit.length - 8) * 0.135;
			if(optionShit.length < 6) scr = 0;
			menuItem.scrollFactor.set(0, scr);
			menuItem.antialiasing = ClientPrefs.globalAntialiasing;
			//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
			menuItem.updateHitbox();
			if (firstStart)
				FlxTween.tween(menuItem, {y: 15 + (i * 137)}, 1 + (i * 0.25), {
					ease: FlxEase.expoInOut,
					onComplete: function(flxTween:FlxTween)
					{
						finishedFunnyMove = true;
						changeItem();
					}
				});
			else
				FlxTween.tween(menuItem, {y: 15 + (i * 137)}, 1 + (i * 0.25), {
					ease: FlxEase.expoInOut,
					onComplete: function(flxTween:FlxTween)
					{
						finishedFunnyMove = true;
						changeItem();
					}
				});
		}

		firstStart = false;
		
		FlxG.camera.follow(camFollowPos, null, 1);

		iconStory = new FlxSprite(500, -150).loadGraphic(Paths.image('menuicons/story'));
		add(iconStory);
		iconStory.visible = false;
		
		iconFreeplay = new FlxSprite(400, 50).loadGraphic(Paths.image('menuicons/freeplay'));
		add(iconFreeplay);
		iconFreeplay.visible = false;

		iconCredits = new FlxSprite(450, 300).loadGraphic(Paths.image('menuicons/lol'));
		add(iconCredits);
		iconCredits.visible = false;

		iconOptions = new FlxSprite(450, 450).loadGraphic(Paths.image('menuicons/options'));
		add(iconOptions);
		iconOptions.visible = false;

		iconAwards = new FlxSprite(420, 200).loadGraphic(Paths.image('menuicons/awards'));
		add(iconAwards);
		iconAwards.visible = false;

		var versionShit:FlxText = new FlxText(12, FlxG.height - 44, 0, "Psych Engine v" + psychEngineVersion, 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);
		var versionShit:FlxText = new FlxText(12, FlxG.height - 24, 0, "FNF Vs Splats: v1.0", 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		FlxG.camera.zoom = 30;
		bg.angle = 75;
		FlxTween.tween(FlxG.camera, {zoom: 1}, 1.1, {ease: FlxEase.expoOut});
		FlxTween.tween(bg, {angle: 0}, 1.1, {ease: FlxEase.expoOut});

		// NG.core.calls.event.logEvent('swag').send();

		changeItem();

		#if ACHIEVEMENTS_ALLOWED
		Achievements.loadAchievements();
		var leDate = Date.now();
		if (!Achievements.achievementsUnlocked[achievementID][1] && leDate.getDay() == 5 && leDate.getHours() >= 18) { //It's a friday night. WEEEEEEEEEEEEEEEEEE
			Achievements.achievementsUnlocked[achievementID][1] = true;
			giveAchievement();
			ClientPrefs.saveSettings();
		}
		#end

		super.create();
	}

	#if ACHIEVEMENTS_ALLOWED
	// Unlocks "Freaky on a Friday Night" achievement
	var achievementID:Int = 0;
	function giveAchievement() {
		add(new AchievementObject(achievementID, camAchievement));
		FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);
		trace('Giving achievement ' + achievementID);
	}
	#end

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var lerpVal:Float = CoolUtil.boundTo(elapsed * 5.6, 0, 1);
		camFollowPos.setPosition(FlxMath.lerp(camFollowPos.x, camFollow.x, lerpVal), FlxMath.lerp(camFollowPos.y, camFollow.y, lerpVal));

		if (optionShit[curSelected] == 'story_mode')
		{
			changeItem(-1);
			changeItem(1);

			iconStory.updateHitbox();
			iconStory.visible = true;
		}
		else
		{
			iconStory.visible = false;
		}

		if (optionShit[curSelected] == 'freeplay')
		{
			changeItem(-1);
			changeItem(1);

			iconFreeplay.updateHitbox();
			iconFreeplay.visible = true;
		}
		else
		{
			iconFreeplay.visible = false;
		}

		if (optionShit[curSelected] == 'credits')
		{
			changeItem(-1);
			changeItem(1);

			iconCredits.updateHitbox();
			iconCredits.visible = true;
		}
		else
		{
			iconCredits.visible = false;
		}

		if (optionShit[curSelected] == 'options')
		{
			changeItem(-1);
			changeItem(1);

			iconOptions.updateHitbox();
			iconOptions.visible = true;
		}
		else
		{
			iconOptions.visible = false;
		}

		
		if (optionShit[curSelected] == 'awards')
		{
			changeItem(-1);
			changeItem(1);

			iconAwards.updateHitbox();
			iconAwards.visible = true;
		}
		else
		{
			iconAwards.visible = false;
		}


		if (!selectedSomethin)
		{
			if (controls.UI_UP_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (controls.UI_DOWN_P)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				selectedSomethin = true;
				FlxG.sound.play(Paths.sound('cancelMenu'));
				MusicBeatState.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					CoolUtil.browserLoad('https://ninja-muffin24.itch.io/funkin');
				}
				else
				{
					selectedSomethin = true;
					FlxG.sound.play(Paths.sound('confirmMenu'));

					if(ClientPrefs.flashing) FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxG.camera.flash(FlxColor.WHITE, 0.5);
							FlxG.camera.shake(0.002);
						}
						else
						{
							FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
							{
								var daChoice:String = optionShit[curSelected];

								switch (daChoice)
								{
									case 'story_mode':
										MusicBeatState.switchState(new StoryMenuState());
									case 'freeplay':
										MusicBeatState.switchState(new FreeplayState());
									case 'awards':
										MusicBeatState.switchState(new AchievementsMenuState());
									case 'credits':
										MusicBeatState.switchState(new CreditsState());
									case 'options':
										MusicBeatState.switchState(new OptionsState());
								}
							});
						}
					});
				}
			}
			#if desktop
			else if (FlxG.keys.justPressed.SEVEN)
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			//spr.screenCenter(X);
		});
	}

	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{	
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');
			spr.offset.y = 0;
			spr.updateHitbox();

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
				spr.offset.x = 0.15 * (spr.frameWidth / 2 + 180);
				spr.offset.y = 0.15 * spr.frameHeight;
				FlxG.log.add(spr.frameWidth);
			}
		});
	}
}
