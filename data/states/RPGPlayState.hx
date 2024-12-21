package;

import flixel.math.FlxPoint;
import flixel.input.FlxPointer;
import RPGObjects.RPGCollision;
import flixel.addons.transition.FlxTransitionableState;
import RPGObjects.RPGObject;
import flixel.util.FlxSpriteUtil;
import editors.RPGMapChartEditorState;
#if desktop
import Discord.DiscordClient;
#end
import RPGAreas.CoolArea;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.group.FlxSpriteGroup;
import DialogueBoxPsych;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;

using StringTools;

class RPGPlayState extends RPGAreaState
{
    public static var AREA:CoolArea = null;

    public var camHUD:FlxCamera;
	public var camCONTENT:FlxCamera;
    public var camSKYBOX:FlxCamera;

    var skybox:FlxSprite = new FlxSprite();
	var pauseButton:FlxSprite = new FlxSprite();
	var inventoryButton:FlxSprite = new FlxSprite();
	var marker:FlxSprite = new FlxSprite();

    var inCutscene = false;
	var paused = false;
    var dialogueJson:DialogueFile = null;

	var characterIdleTimer:Float = 0;
	var angleHandler:String = 'DOWN';
	var frameHandler:Int = 0;

	var RPGCharacter:RPGCharacter;
	var characterGroup:FlxTypedSpriteGroup<Dynamic> = new FlxTypedSpriteGroup<Dynamic>();
	var charCont:FlxSprite;

	var exampleObject:RPGObject;

	var curExit = '';
	var curCharacter = '';
	var curLayer = '';
	var curMusic = '';
	var curSkybox = '';

	var worldGenerated = false;
	var transitioning = false;
	var inInventory = false;

	var usedExits:Array<Dynamic> = []; //first dialogues for exits check
	var usedDialogue:Array<Dynamic> = []; //ditto, but for areas
	var usedItems:Array<Dynamic> = []; //ditto, but for items
	var usedObjects:Array<Dynamic> = []; //ditto, but for objects
	var objectsToRemove:Array<Dynamic> = []; //check which objects shouldn't exist

	var objectItems:Array<Dynamic> = []; //this will be for checking what items objects require

	var finishedObjects = [];

	var chosenObject:Dynamic; //Which object to interact wit

	var currentItems:Array<Dynamic> = []; //items equipped

	var inventoryGroup = new FlxTypedSpriteGroup<Dynamic>();

	//Objects
    var FBItems = new FlxTypedSpriteGroup<Dynamic>();
	var BItems = new FlxTypedSpriteGroup<Dynamic>();
	var MItems = new FlxTypedSpriteGroup<Dynamic>();
	var FItems = new FlxTypedSpriteGroup<Dynamic>();
	var FFItems = new FlxTypedSpriteGroup<Dynamic>();

	//Item Ranges
	var FBRanges = new FlxTypedSpriteGroup<Dynamic>();
	var BRanges = new FlxTypedSpriteGroup<Dynamic>();
	var MRanges = new FlxTypedSpriteGroup<Dynamic>();
	var FRanges = new FlxTypedSpriteGroup<Dynamic>();
	var FFRanges = new FlxTypedSpriteGroup<Dynamic>();

	//Exits
	var FBExits = new FlxTypedSpriteGroup<Dynamic>();
	var BExits = new FlxTypedSpriteGroup<Dynamic>();
	var MExits = new FlxTypedSpriteGroup<Dynamic>();
	var FExits = new FlxTypedSpriteGroup<Dynamic>();
	var FFExits = new FlxTypedSpriteGroup<Dynamic>();

	//Collisions
	var FBCollision = new FlxTypedSpriteGroup<Dynamic>();
	var BCollision = new FlxTypedSpriteGroup<Dynamic>();
	var MCollision = new FlxTypedSpriteGroup<Dynamic>();
	var FCollision = new FlxTypedSpriteGroup<Dynamic>();
	var FFCollision = new FlxTypedSpriteGroup<Dynamic>();

	var inventorySprite:FlxSprite;

	// Debug buttons
	private var debugKeysMap:Array<FlxKey>;

    override function create() {
		Paths.clearStoredMemory();

		if (AREA == null)
			AREA = RPGAreas.loadFromJson('Test');

		debugKeysMap = ClientPrefs.copyKey(ClientPrefs.keyBinds.get('debug_1'));

		Achievements.loadAchievements();
		
        persistentUpdate = true;
        persistentDraw = true;

        //Camera Setup
        camSKYBOX = new FlxCamera(); //SKYBOX Layer
		camCONTENT = new FlxCamera(); //CONTENT Layer
        camCONTENT.bgColor.alpha = 0;
		camHUD = new FlxCamera(); //HUD Layer
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camSKYBOX);
        FlxG.cameras.add(camCONTENT);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camHUD];
		
		skybox.cameras = [camSKYBOX];
		add(skybox);

		characterGroup.cameras = [camCONTENT];
		characterGroup.visible = false;
		add(characterGroup);

		RPGCharacter = new RPGCharacter(0,0, (curCharacter == '' ? AREA.character : curCharacter));
		curCharacter = AREA.character;
		createCharacter();

		charCont = new FlxSprite(0,0).makeGraphic(1, 1, 0x00000000);
		charCont.cameras = [camCONTENT];

		setupLayers();

		pauseButton.frames = Paths.getSparrowAtlas('RPGUI');
		pauseButton.animation.addByPrefix('idle', "Pause_Idle", 24);
		pauseButton.animation.addByPrefix('select', "Pause_Select", 24);
		pauseButton.animation.play('idle');
		add(pauseButton);
		pauseButton.y = 10;
		pauseButton.x = FlxG.width + pauseButton.width + 10;
		pauseButton.antialiasing = ClientPrefs.globalAntialiasing;

		inventoryButton.frames = Paths.getSparrowAtlas('RPGUI2');
		inventoryButton.animation.addByPrefix('idle', "Inv_Idle", 24);
		inventoryButton.animation.addByPrefix('select', "Inv_Select", 24);
		inventoryButton.animation.play('idle');
		add(inventoryButton);
		inventoryButton.y = FlxG.height - inventoryButton.height - 10;
		inventoryButton.x = FlxG.width + inventoryButton.width + 10;
		inventoryButton.antialiasing = ClientPrefs.globalAntialiasing;

		add(inventoryGroup);

		buildInventory();
		
        createWorld();

		marker.frames = Paths.getSparrowAtlas('Marker');
		marker.animation.addByPrefix('idle', "Appear", 24, false);
		marker.animation.play('idle');
		marker.cameras = [camCONTENT];

		characterIdleTimer = RPGCharacter.idleTime;

        super.create();
		Paths.clearUnusedMemory();
    }

	function buildInventory() {
		inventoryGroup.y = 0;
		inventoryGroup.x = 0;

		inventorySprite = new FlxSprite(0,0).loadGraphic(Paths.image('InventoryBar'));  
		inventorySprite.antialiasing = ClientPrefs.globalAntialiasing;
		inventoryGroup.add(inventorySprite);

		for (i in 0...currentItems.length) {
			var item = currentItems[i];
			var itemImage = new FlxSprite(0,0);

			if(Paths.fileExists('images/' + item.imagePath + '.txt', TEXT)) {
				itemImage.frames = Paths.getPackerAtlas(item.imagePath);
			} else {
				itemImage.frames = Paths.getSparrowAtlas(item.imagePath);
			}
			itemImage.animation.addByPrefix('idle', 'loop', 24, true);
			itemImage.animation.play('idle');

			itemImage.antialiasing = ClientPrefs.globalAntialiasing;
			itemImage.setGraphicSize(45, 0);
			itemImage.updateHitbox();
			if (itemImage.height > 45) {
				itemImage.setGraphicSize(0, 45);
				itemImage.updateHitbox();
			}

			itemImage.x = inventorySprite.x + inventorySprite.width / 2 - itemImage.width / 2;
			itemImage.y = 62 + (i * (52.75)) - itemImage.height / 2;

			inventoryGroup.add(itemImage);
		}

		inventoryGroup.y = FlxG.height/2 - inventoryGroup.height/2;
		if (!inInventory)
			inventoryGroup.x = FlxG.width + 10;
		else
			inventoryGroup.x = FlxG.width - inventoryGroup.width;
	}

	function setupLayers() {
		FBCollision.cameras = [camCONTENT];
		FBCollision.visible = false;
		add(FBCollision);
		FBRanges.cameras = [camCONTENT];
		FBRanges.visible = false;
		add(FBRanges);
        FBItems.cameras = [camCONTENT];
		add(FBItems);
		FBExits.cameras = [camCONTENT];
		FBExits.visible = false;
		add(FBExits);

		BCollision.cameras = [camCONTENT];
		BCollision.visible = false;
		add(BCollision);
		BRanges.cameras = [camCONTENT];
		BRanges.visible = false;
		add(BRanges);
		BItems.cameras = [camCONTENT];
		add(BItems);
		BExits.cameras = [camCONTENT];
		BExits.visible = false;
		add(BExits);

		MCollision.cameras = [camCONTENT];
		MCollision.visible = false;
		add(MCollision);
		MRanges.cameras = [camCONTENT];
		MRanges.visible = false;
		add(MRanges);
		MItems.cameras = [camCONTENT];
		add(MItems);
		MExits.cameras = [camCONTENT];
		MExits.visible = false;
		add(MExits);

		FCollision.cameras = [camCONTENT];
		FCollision.visible = false;
		add(FCollision);
		FRanges.cameras = [camCONTENT];
		FRanges.visible = false;
		add(FRanges);
		FItems.cameras = [camCONTENT];
		add(FItems);
		FExits.cameras = [camCONTENT];
		FExits.visible = false;
		add(FExits);

		FFCollision.cameras = [camCONTENT];
		FFCollision.visible = false;
		add(FFCollision);
		FFRanges.cameras = [camCONTENT];
		FFRanges.visible = false;
		add(FFRanges);
		FFItems.cameras = [camCONTENT];
		add(FFItems);
		FFExits.cameras = [camCONTENT];
		FFExits.visible = false;
		add(FFExits);
	}

	var exitSound = '';
	var destination_exit = '';
	var leadsToState = false;

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        if (!inCutscene) {
			var lerpVal:Float = CoolUtil.boundTo(elapsed * 6.2, 0, 1);

			if (!transitioning && !inInventory) {
				collisionCheck();
				keyShit();
				sortLayer(curLayer);
			}
	
			if (!transitioning && inInventory)
				inventoryShit();
			//if controlMode is Mouse and the button is clicked and overlaps the mouse, or if controlmode is keyboard and UI_BACK is pressed, pause the game
			if (!transitioning) {
				if ((controlMode == "Mouse" && FlxG.mouse.justPressed && FlxG.mouse.overlaps(pauseButton)) || (controlMode == 'Keyboard' && controls.BACK && !inInventory)) {
					pauseGame();
				}

				if (controlMode == "Mouse" && FlxG.mouse.justPressed && FlxG.mouse.overlaps(inventoryButton)) {
					inInventory = !inInventory;
					mouseMoving = false;
					keyboardMoving = false;
				}

				if (controlMode == 'Keyboard' && controls.ACCEPT && !inInventory) {
					inInventory = true;
					mouseMoving = false;
					keyboardMoving = false;
				}

				if (controlMode == 'Keyboard' && controls.BACK && inInventory) {
					inInventory = false;
				}

				if (worldGenerated) {

					if (!keyboardMoving && !mouseMoving) {
						animationHandler('stand');
					}

					if (keyboardMoving || mouseMoving) {
						checkExitCollision();
					}

					if ((!keyboardMoving && !mouseMoving && chosenObject == null))
						checkRangeCollision();

					if (!inInventory && chosenObject != null && chosenObject != 'sus' && ((controlMode == 'Mouse' && FlxG.mouse.justPressedRight) || (controlMode == 'Keyboard' && controls.UI_SHIFT_P))) {
						if (chosenObject.type == "Item" && currentItems.length < 10) {
							usedItems.push(AREA.name + '_' + chosenObject.name);

							var itemDef = {
								name: chosenObject.name != '' ? chosenObject.name : 'default',
								imagePath: chosenObject.imagePath,
							}

							currentItems.push(itemDef);

							var itemImage = new FlxSprite(0,0);
							if(Paths.fileExists('images/' + chosenObject.imagePath + '.txt', TEXT)) {
								itemImage.frames = Paths.getPackerAtlas(chosenObject.imagePath);
							} else {
								itemImage.frames = Paths.getSparrowAtlas(chosenObject.imagePath);
							}
							itemImage.animation.addByPrefix('idle', 'loop', 24, true);
							itemImage.animation.play('idle');

							itemImage.antialiasing = ClientPrefs.globalAntialiasing;
							itemImage.setGraphicSize(45, 0);
							itemImage.updateHitbox();
							if (itemImage.height > 45) {
								itemImage.setGraphicSize(0, 45);
								itemImage.updateHitbox();
							}

							itemImage.x = inventorySprite.width / 2 - itemImage.width / 2;
							itemImage.y = 62 + ((inventoryGroup.length - 1) * (52.75)) - itemImage.height / 2;

							inventoryGroup.add(itemImage);

							remove(marker);

							chosenObject.visible = false;
							chosenObject.pickedUp = true;

							if (chosenObject.interactDialogue != '') {
								processObjectDialogue(chosenObject.interactDialogue);
							}

							chosenObject = null;

							FlxG.sound.play(Paths.sound('ItemAccept'));
						} else if (chosenObject.type == "Item" && currentItems.length >= 10) {
							FlxG.sound.play(Paths.sound('ItemDeny'));
							var file:String;
							file = Paths.json('RPG_Dialogue/${curCharacter}.toomanyitems');
							try {
								dialogueJson = DialogueBoxPsych.parseDialogue(file);
							} catch (error) {
								dialogueJson = DialogueBoxPsych.parseDialogue(Paths.json('RPG_Dialogue/_generic.toomanyitems'));
							}
							startDialogue(dialogueJson);
						}
						
						if (chosenObject.type != "Item") {
							if (chosenObject.requiredItems.length > 0) {
								var needsToAdd = true;
								for (i in 0...objectItems.length) {
									if (objectItems[i].name == AREA.name + '_' + chosenObject.name)
										needsToAdd = false;
								}

								if (needsToAdd) {
								var neededShit = {
									name: AREA.name + '_' + chosenObject.name,
									requiredItems: chosenObject.requiredItems,
									exactOrder: chosenObject.exactOrder,
									changeSprites: chosenObject.changeSprites,
									amount: chosenObject.requiredItems.length
								}

								objectItems.push(neededShit);
								}
							}

							if (!finishedObjects.contains(AREA.name + '_' + chosenObject.name)) {
								if (chosenObject.firstDialogue != '' && !usedObjects.contains(AREA.name + '_' + chosenObject.name)) {
									usedObjects.push(AREA.name + '_' + chosenObject.name);
									
									if (chosenObject.action == '')
										processObjectDialogue(chosenObject.firstDialogue);
									else 
										processObjectDialogue(chosenObject.firstDialogue, 'action');
								} else {
									if (chosenObject.firstDialogue == '' && chosenObject.interactDialogue == '' && chosenObject.action != '')
										proceedWithAction();

									if (chosenObject.interactDialogue != '') {
										if (chosenObject.action == '')
											processObjectDialogue(chosenObject.interactDialogue);
										else 
											processObjectDialogue(chosenObject.interactDialogue, 'action');
									} else 
										proceedWithAction();
								}
							} else {
								if (chosenObject.allDialogue != '') {
									processObjectDialogue(chosenObject.allDialogue);
								} else if (chosenObject.rightDialogue != '') {
									processObjectDialogue(chosenObject.rightDialogue);
								} else if (chosenObject.interactDialogue != '') {
									processObjectDialogue(chosenObject.interactDialogue);
								}
							}
						}
					}
				}
			}
			pauseButton.x = FlxMath.lerp(pauseButton.x,(controlMode == "Mouse" ? FlxG.width - pauseButton.width - 10 :  FlxG.width + 10), lerpVal);
			inventoryButton.x = pauseButton.x;
			inventoryGroup.x = FlxMath.lerp(inventoryGroup.x,(inInventory == true ? FlxG.width - inventoryGroup.width :  FlxG.width + 30), lerpVal);

			//When Mouse is overlapping the button, change its animation but make sure the offset is correct
			if (FlxG.mouse.overlaps(pauseButton)) {
				pauseButton.animation.play('select');
				pauseButton.offset.y = 4;
				//lerp the scale
				pauseButton.scale.x = FlxMath.lerp(pauseButton.scale.x, 1.2, lerpVal);
				pauseButton.scale.y = pauseButton.scale.x;
			} else {
				pauseButton.animation.play('idle');
				pauseButton.scale.x = FlxMath.lerp(pauseButton.scale.x, 1, lerpVal);
				pauseButton.scale.y = pauseButton.scale.x;
				pauseButton.offset.y = 0;
			}

			if (FlxG.mouse.overlaps(inventoryButton)) {
				inventoryButton.animation.play('select');
				inventoryButton.scale.x = FlxMath.lerp(inventoryButton.scale.x, 1.2, lerpVal);
				inventoryButton.scale.y = inventoryButton.scale.x;
			} else {
				inventoryButton.animation.play('idle');
				inventoryButton.scale.x = FlxMath.lerp(inventoryButton.scale.x, 1, lerpVal);
				inventoryButton.scale.y = inventoryButton.scale.x;
			}

			#if debug
			if (FlxG.keys.anyJustPressed(debugKeysMap) && !inCutscene)
				{
					persistentUpdate = false;
					CustomFadeTransition.nextCamera = camHUD;
					RPGAreaState.switchState(new RPGMapChartEditorState());
		
					#if desktop
					DiscordClient.changePresence("Map Editor", null, null, true);
					#end
				}
			#end
		}
    }

	var leftCollided:Bool = false;
	var rightCollided:Bool = false;
	var upCollided:Bool = false;
	var downCollided:Bool = false;

	function collisionCheck() {
		leftCollided = (sensor_left.x <= AREA.cameraBounds[0] - FlxG.width/2);
		rightCollided = (sensor_right.x + sensor_right.width >= AREA.cameraBounds[1] - FlxG.width/2);
		upCollided = (sensor_up.y <= AREA.cameraBounds[2] - FlxG.height/2);
		downCollided = (sensor_down.y + sensor_down.height >= AREA.cameraBounds[3] - FlxG.height/2);

		switch (curLayer) {
			case 'middle':
				if (!leftCollided) {
					for (object in 0...MCollision.members.length) {
						leftCollided = FlxG.pixelPerfectOverlap(sensor_left, MCollision.members[object]);
						if (leftCollided) {
							break;
						}
					}
				}

				if (!rightCollided) {
					for (object in 0...MCollision.members.length) {
						rightCollided = FlxG.pixelPerfectOverlap(sensor_right, MCollision.members[object]);
						if (rightCollided) {
							break;
						}
					}
				}

				if (!upCollided) {
					for (object in 0...MCollision.members.length) {
						upCollided = FlxG.pixelPerfectOverlap(sensor_up, MCollision.members[object]);
						if (upCollided) {
							break;
						}
					}
				}

				if (!downCollided) {
					for (object in 0...MCollision.members.length) {
						downCollided = FlxG.pixelPerfectOverlap(sensor_down, MCollision.members[object]);
						if (downCollided) {
							break;
						}
					}
				}
			case 'foreground':
				if (!leftCollided) {
					for (object in 0...FCollision.members.length) {
						leftCollided = FlxG.pixelPerfectOverlap(sensor_left, FCollision.members[object]);
						if (leftCollided) {
							break;
						}
					}
				}

				if (!rightCollided) {
					for (object in 0...FCollision.members.length) {
						rightCollided = FlxG.pixelPerfectOverlap(sensor_right, FCollision.members[object]);
						if (rightCollided) {
							break;
						}
					}
				}

				if (!upCollided) {
					for (object in 0...FCollision.members.length) {
						upCollided = FlxG.pixelPerfectOverlap(sensor_up, FCollision.members[object]);
						if (upCollided) {
							break;
						}
					}
				}

				if (!downCollided) {
					for (object in 0...FCollision.members.length) {
						downCollided = FlxG.pixelPerfectOverlap(sensor_down, FCollision.members[object]);
						if (downCollided) {
							break;
						}
					}
				}
			case 'background':
				if (!leftCollided) {
					for (object in 0...BCollision.members.length) {
						leftCollided = FlxG.pixelPerfectOverlap(sensor_left, BCollision.members[object]);
						if (leftCollided) {
							break;
						}
					}
				}

				if (!rightCollided) {
					for (object in 0...BCollision.members.length) {
						rightCollided = FlxG.pixelPerfectOverlap(sensor_right, BCollision.members[object]);
						if (rightCollided) {
							break;
						}
					}
				}

				if (!upCollided) {
					for (object in 0...BCollision.members.length) {
						upCollided = FlxG.pixelPerfectOverlap(sensor_up, BCollision.members[object]);
						if (upCollided) {
							break;
						}
					}
				}

				if (!downCollided) {
					for (object in 0...BCollision.members.length) {
						downCollided = FlxG.pixelPerfectOverlap(sensor_down, BCollision.members[object]);
						if (downCollided) {
							break;
						}
					}
				}
			case 'far background':
				if (!leftCollided) {
					for (object in 0...FBCollision.members.length) {
						leftCollided = FlxG.pixelPerfectOverlap(sensor_left, FBCollision.members[object]);
						if (leftCollided) {
							break;
						}
					}
				}

				if (!rightCollided) {
					for (object in 0...FBCollision.members.length) {
						rightCollided = FlxG.pixelPerfectOverlap(sensor_right, FBCollision.members[object]);
						if (rightCollided) {
							break;
						}
					}
				}

				if (!upCollided) {
					for (object in 0...FBCollision.members.length) {
						upCollided = FlxG.pixelPerfectOverlap(sensor_up, FBCollision.members[object]);
						if (upCollided) {
							break;
						}
					}
				}

				if (!downCollided) {
					for (object in 0...FBCollision.members.length) {
						downCollided = FlxG.pixelPerfectOverlap(sensor_down, FBCollision.members[object]);
						if (downCollided) {
							break;
						}
					}
				}
			case 'far foreground':
				if (!leftCollided) {
					for (object in 0...FFCollision.members.length) {
						leftCollided = FlxG.pixelPerfectOverlap(sensor_left, FFCollision.members[object]);
						if (leftCollided) {
							break;
						}
					}
				}

				if (!rightCollided) {
					for (object in 0...FFCollision.members.length) {
						rightCollided = FlxG.pixelPerfectOverlap(sensor_right, FFCollision.members[object]);
						if (rightCollided) {
							break;
						}
					}
				}

				if (!upCollided) {
					for (object in 0...FFCollision.members.length) {
						upCollided = FlxG.pixelPerfectOverlap(sensor_up, FFCollision.members[object]);
						if (upCollided) {
							break;
						}
					}
				}

				if (!downCollided) {
					for (object in 0...FFCollision.members.length) {
						downCollided = FlxG.pixelPerfectOverlap(sensor_down, FFCollision.members[object]);
						if (downCollided) {
							break;
						}
					}
				}
		}
	}

	function processObjectDialogue(dialogue:String, ?action:String = null) {
		var file:String = Paths.json('RPG_Dialogue/' + dialogue); //Checks for json/Psych Engine dialogue
		dialogueJson = DialogueBoxPsych.parseDialogue(file);
		startDialogue(dialogueJson, action);
	}

	override public function onFocusLost():Void{
		#if desktop
		if (!paused && worldGenerated && ClientPrefs.automaticPause && !transitioning)
			pauseGame();
		#end
	
		super.onFocusLost();
	}

	override function closeSubState()
		{
			if (paused)
			{
				paused = false;
				FlxG.sound.music.fadeIn(0.5, 0.2, 0.6);

				if (controlMode == "Mouse")
					FlxG.mouse.visible = true;

				#if desktop
				// Updating Discord Rich Presence.
				DiscordClient.changePresence(detailsText, "As: " + curCharacter, null);
				#end
			}
	
			super.closeSubState();
		}

	function pauseGame() {
		paused = true;
		persistentUpdate = false;
		persistentDraw = true;

		if(FlxG.sound.music != null)
			FlxG.sound.music.fadeOut(0.5, 0.2);

		RPGPause.transCamera = camHUD;
		openSubState(new RPGPause(0, 0));

		#if desktop
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(pausedDetailsText, null, null);
		#end
	}

	var mouseX:Float;
	var mouseY:Float;
	var mouseMoving:Bool;

	var MoveSpeed:Float = 4;

	var keyboardMoving:Bool;

	var collisionCheckTimer:Int = 100;

    private function keyShit():Void {
        var up = controls.UI_UP;
        var right = controls.UI_RIGHT;
        var down = controls.UI_DOWN;
        var left = controls.UI_LEFT;
        var shift = controls.UI_SHIFT;

        var controlHoldArray:Array<Bool> = [left, down, up, right];

		if (!controlHoldArray.contains(true) && keyboardMoving) {
			keyboardMoving = false;
			characterIdleTimer = RPGCharacter.idleTime;
		}

        if (controlHoldArray.contains(true) && controlMode == 'Keyboard' && !inCutscene) {

			MoveSpeed = RPGCharacter.walkSpeed * (shift ? RPGCharacter.runCoefficient : 1);

            if (up && !upCollided) {
                charCont.y -= MoveSpeed;
            } else if (down && !downCollided) {
                charCont.y += MoveSpeed;
            }

            if (left && !leftCollided) {
                charCont.x -= MoveSpeed;
            } else if (right && !rightCollided) {
                charCont.x += MoveSpeed;
            }

			dynamicPos(charCont.x, charCont.y);

			if (!keyboardMoving)
				keyboardMoving = true;

			if (chosenObject != null) {
				chosenObject = null;
				remove(marker);
			}

			if (characterIdleTimer != RPGCharacter.idleTime)
				characterIdleTimer = RPGCharacter.idleTime;

			xChange = left ? -1 : right ? 1 : 0;
			yChange = up ? -1 : down ? 1 : 0;
			animationHandler(shift ? 'run' : 'walk');
        }

		if (controlMode == 'Mouse' && FlxG.mouse.justPressed && !inCutscene && !FlxG.mouse.overlaps(pauseButton) && !FlxG.mouse.overlaps(inventoryGroup) && !FlxG.mouse.overlaps(inventoryButton)) {
			mouseMoving = true;
			var pointer:FlxPoint = new FlxPoint(0,0);
			FlxG.mouse.getScreenPosition(camCONTENT, pointer);
			mouseX = pointer.x - FlxG.width / 2 / camCONTENT.zoom;
			mouseY = pointer.y - FlxG.height / 2 / camCONTENT.zoom;
			if (chosenObject != null) {
				chosenObject = null;
				remove(marker);
			}
		}

		if (controlMode == 'Keyboard' && mouseMoving) {
			mouseMoving = false;
			collisionCheckTimer = 100;
		}

		if (controlMode == 'Mouse' && keyboardMoving) {
			keyboardMoving = false;
		}

		//move characterGroup when mousemoving is true constantly until their position is relatively similar to mousex and mousey.
		//if the position is similar enough, set mousemoving to false
		//if the mouse has been clicked under a really short amount of time, make it move faster
		if (mouseMoving) {

			if ((Math.abs(mouseX - charCont.x - charCont.width / 2) <= 1 + MoveSpeed && Math.abs(mouseY - charCont.y - charCont.height) <= 1 + MoveSpeed) || collisionCheckTimer <= 0) {
				mouseMoving = false;
				collisionCheckTimer = 100;
				characterIdleTimer = RPGCharacter.idleTime;
			}

			if (((leftCollided || rightCollided) && Math.abs(mouseY - charCont.y - charCont.height) <= 1 + MoveSpeed)
			|| ((upCollided || downCollided) && Math.abs(mouseX - charCont.x - charCont.width / 2) <= 1 + MoveSpeed))
				collisionCheckTimer--;
			else
				collisionCheckTimer = 100;

			MoveSpeed = RPGCharacter.walkSpeed * (FlxG.mouse.pressedRight ? RPGCharacter.runCoefficient : 1);

			if (characterIdleTimer != RPGCharacter.idleTime)
				characterIdleTimer = RPGCharacter.idleTime;

			//keep moving characterGroup until the mouse is within a certain distance of the mouseX and mouseY
			if (Math.abs(mouseX - charCont.x - charCont.width / 2) > 1 + MoveSpeed) {
				if (mouseX < charCont.x && !leftCollided) {
					charCont.x -= MoveSpeed;
				} else if (mouseX > charCont.x && !rightCollided) {
					charCont.x += MoveSpeed;
				}
			}

			if (Math.abs(mouseY - charCont.y - charCont.height) > 1 + MoveSpeed) {
				if (mouseY < charCont.y && !upCollided) {
					charCont.y -= MoveSpeed;
				} else if (mouseY > charCont.y && !downCollided) {
					charCont.y += MoveSpeed;
				}
			}

			if (Math.abs(mouseX - charCont.x - charCont.width / 2) <= 1 + MoveSpeed) {
				charCont.x = mouseX - charCont.width / 2;
			}

			if (Math.abs(mouseY - charCont.y - charCont.height) <= 1 + MoveSpeed) {
				charCont.y = mouseY - charCont.height;
			}

			dynamicPos(charCont.x, charCont.y);

			xChange = mouseX - charCont.x - charCont.width / 2;
			yChange = mouseY - charCont.y - charCont.height;
			animationHandler(FlxG.mouse.pressedRight ? 'run' : 'walk');
		}
    }

	var curSelected = 0;

	function inventoryShit() {
		for (i in 0...currentItems.length) {
			if (i == curSelected) {
				inventoryGroup.members[i+1].alpha = 1;
			} else {
				inventoryGroup.members[i+1].alpha = 0.5;
			}
		}

		if (controlMode == "Keyboard") {
			if (currentItems.length != 0) {
				if (controls.UI_UP_P) {
					curSelected--;
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}

				if (controls.UI_DOWN_P) {
					curSelected++;
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}

				if (curSelected < 0)
					curSelected = currentItems.length - 1;

				if (curSelected > currentItems.length - 1)
					curSelected = 0;

				if (controls.ACCEPT) {
					checkItem();
				}

			} else if (currentItems.length == 0 && curSelected != 0)
				curSelected = 0;
		} else {
			if (FlxG.mouse.overlaps(inventoryGroup)) {
				for (i in 0...inventoryGroup.members.length) {
					if (inventoryGroup.members[i] != inventorySprite && FlxG.mouse.overlaps(inventoryGroup.members[i])) {
						curSelected = i - 1;
						break;
					}
				}
			}

			if (inventoryGroup.members[curSelected] != inventorySprite && FlxG.mouse.overlaps(inventoryGroup.members[curSelected+1]) && FlxG.mouse.justPressed) {
				checkItem();
			}
		}
	}

	function checkItem() {
		if ((chosenObject != null && chosenObject != 'sus' && chosenObject.type == 'Item') || chosenObject == null || chosenObject == 'sus') {
			FlxG.sound.play(Paths.sound('ItemDeny'));

			var file:String;
			file = Paths.json('RPG_Dialogue/${curCharacter}.wrongplace');
			try {
				dialogueJson = DialogueBoxPsych.parseDialogue(file);
			} catch (error) {
				dialogueJson = DialogueBoxPsych.parseDialogue(Paths.json('RPG_Dialogue/_generic.wrongplace'));
			}
			startDialogue(dialogueJson);
		} else {
			var canInteract = false;
			var indexToReference = 0;
			for (i in 0...objectItems.length) {
				if (objectItems[i].name == AREA.name + '_' + chosenObject.name) {
					canInteract = true;
					indexToReference = i;
				}
			}

			if (!canInteract) {
				FlxG.sound.play(Paths.sound('ItemDeny'));

				var file:String;
				file = Paths.json('RPG_Dialogue/${curCharacter}.whatitems');
				try {
					dialogueJson = DialogueBoxPsych.parseDialogue(file);
				} catch (error) {
					dialogueJson = DialogueBoxPsych.parseDialogue(Paths.json('RPG_Dialogue/_generic.whatitems'));
				}
				startDialogue(dialogueJson);
			} else {
				var objectToReference:Dynamic = objectItems[indexToReference];

				if (objectToReference.exactOrder) {
					if (objectToReference.requiredItems[0] == currentItems[curSelected].name) {
						FlxG.sound.play(Paths.sound('ItemAccept'));

						triggerCorrectResponse(objectToReference, 0);
					} else {
						FlxG.sound.play(Paths.sound('ItemDeny'));
						if (chosenObject.wrongDialogue != '') {
							processObjectDialogue(chosenObject.wrongDialogue);
						}
					}
				} else {
					var numberToRemove = -1;

					for (i in 0...objectToReference.requiredItems.length) {
						if (objectToReference.requiredItems[i] == currentItems[curSelected].name) {
							numberToRemove = i;
							break;
						}
					}

					if (numberToRemove != -1) {
						FlxG.sound.play(Paths.sound('ItemAccept'));

						triggerCorrectResponse(objectToReference, numberToRemove);
					} else {
						FlxG.sound.play(Paths.sound('ItemDeny'));
						if (chosenObject.wrongDialogue != '') {
							processObjectDialogue(chosenObject.wrongDialogue);
						}
					}
				}
			}
		}
	}

	function triggerCorrectResponse(objectToReference:Dynamic, index:Int) {
		currentItems.remove(currentItems[curSelected]);
		objectToReference.requiredItems.remove(objectToReference.requiredItems[index]);
		if (curSelected > currentItems.length - 1)
			curSelected = currentItems.length - 1;

		inventoryGroup.clear();
		buildInventory();

		var whattoChangeto = objectToReference.amount - objectToReference.requiredItems.length;

		if (objectToReference.requiredOrder && objectToReference.changeSprites) {
			if(Paths.fileExists('images/' + chosenObject.imagePath + '_${whattoChangeto}' + '.txt', TEXT)) {
				chosenObject.frames = Paths.getPackerAtlas(chosenObject.imagePath + '_${whattoChangeto}');
			} else {
				chosenObject.frames = Paths.getSparrowAtlas(chosenObject.imagePath + '_${whattoChangeto}');
			}
			chosenObject.animation.addByPrefix('idle', 'loop', 24, true);
			chosenObject.animation.play('idle');
		}

		if (objectToReference.requiredItems.length > 0) {
			if (chosenObject.rightDialogue != '') {
				processObjectDialogue(chosenObject.rightDialogue);
			}
		} else {
			if (objectToReference.amount == 1) {
				if (chosenObject.rightDialogue != '') {
					processObjectDialogue(chosenObject.rightDialogue);
				}
			} else {
				if (!finishedObjects.contains(objectToReference.name))
					finishedObjects.push(objectToReference.name);

				if (chosenObject.action == '') {
					if (chosenObject.allDialogue != '') {
						processObjectDialogue(chosenObject.allDialogue);
					} else if (chosenObject.rightDialogue != '') {
						processObjectDialogue(chosenObject.rightDialogue);
					}
				} else {
					if (chosenObject.allDialogue != '') {
						processObjectDialogue(chosenObject.allDialogue, 'action');
					} else if (chosenObject.rightDialogue != '') {
						processObjectDialogue(chosenObject.rightDialogue, 'action');
					} else
						proceedWithAction();
				}
			}
		}
	}

	function getExitValues(exit:Dynamic) {
		keyboardMoving = false;
		mouseMoving = false;

		if (exit.firstExitDialogue != '' && !usedExits.contains(AREA.name + '_' + exit.name)) {
			usedExits.push(AREA.name + '_' + exit.name);
			var file:String = Paths.json('RPG_Dialogue/' + exit.firstExitDialogue); //Checks for json/Psych Engine dialogue
			dialogueJson = DialogueBoxPsych.parseDialogue(file);
			exitSound = exit.exitSound;
			destination_exit = exit.destination;
			leadsToState = exit.leadsToState;
			startDialogue(dialogueJson, 'transition');
		} else {
			if (exit.destination != '') {
				if (exit.leadsToState) {
					FlxTransitionableState.skipNextTransIn = false;
					CustomFadeTransition.nextCamera = camHUD;
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

					if (exit.exitSound != '')
						FlxG.sound.play(Paths.sound(exit.exitSound));

					switch (exit.destination) {
						case 'Title':
							RPGAreaState.switchState(new TitleState());
						case 'Story':
							RPGAreaState.switchState(new StoryMenuState());
						case 'Freeplay':
							RPGAreaState.switchState(new FreeplayState());
						case 'Credits':
							RPGAreaState.switchState(new CreditsState());
						default:
							RPGAreaState.switchState(new MainMenuState());
					}
				} else {
					AREA = RPGAreas.loadFromJson(exit.destination);
					if (exit.exitSound != '')
						FlxG.sound.play(Paths.sound(exit.exitSound));

					curExit = exit.name;
					TransitionRoom();
				}
			}
		}
	}

	function checkExitCollision() {
			switch (curLayer) {
				case 'middle':
					for (i in 0...MExits.members.length) {
						if (hitbox.overlaps(MExits.members[i], true)) {
							//Sound
							var exit = MExits.members[i];
							getExitValues(exit);
							break;
						}
					}
			case 'background':
				for (i in 0...BExits.members.length) {
					if (hitbox.overlaps(BExits.members[i], true)) {
						//Sound
						var exit = BExits.members[i];
						getExitValues(exit);
						break;
					}
				}
			case 'far background':
				for (i in 0...FBExits.members.length) {
					if (hitbox.overlaps(FBExits.members[i], true)) {
						//Sound
						var exit = FBExits.members[i];
						getExitValues(exit);
						break;
					}
				}
			case 'foreground':
				for (i in 0...FExits.members.length) {
					if (hitbox.overlaps(FExits.members[i], true)) {
						//Sound
						var exit = FExits.members[i];
						getExitValues(exit);
						break;
					}
				}
			case 'far foreground':
				for (i in 0...FFExits.members.length) {
					if (hitbox.overlaps(FFExits.members[i], true)) {
						//Sound
						var exit = FFExits.members[i];
						getExitValues(exit);
						break;
					}
				}
			}
	}

	function checkRangeCollision() {

		switch (curLayer) {
			case 'middle':
				for (i in 0...MRanges.members.length) {
					if (hitbox.overlaps(MRanges.members[i], true)) {
						var closestDist:Float = 10;
						var closestDistX:Float = 10;
						for (j in 0...MItems.members.length) {
							var dist:Float = Math.abs((MItems.members[j].y + MItems.members[j].height) - (MRanges.members[i].y + MRanges.members[i].height / 2));
							var distX:Float = Math.abs((MItems.members[j].x + MItems.members[j].width/2) - (MRanges.members[i].x + MRanges.members[i].width / 2));
							if (distX < closestDistX) {
								chosenObject = MItems.members[j];
								closestDistX = distX;
							}
							if (dist < closestDist) {
								chosenObject = MItems.members[j];
								closestDist = dist;
							}
						}
						break;
					}
				}
			case 'background':
				for (i in 0...BRanges.members.length) {
					if (hitbox.overlaps(BRanges.members[i], true)) {
						var closestDist:Float = 10;
						var closestDistX:Float = 10;
						for (j in 0...BItems.members.length) {
							var dist:Float = Math.abs((BItems.members[j].y + BItems.members[j].height) - (BRanges.members[i].y + BRanges.members[i].height / 2));
							var distX:Float = Math.abs((BItems.members[j].x + BItems.members[j].width/2) - (BRanges.members[i].x + BRanges.members[i].width / 2));
							if (distX < closestDistX) {
								chosenObject = BItems.members[j];
								closestDistX = distX;
							}
							if (dist < closestDist) {
								chosenObject = BItems.members[j];
								closestDist = dist;
							}
						}
						break;
					}
				}
			case 'far background':
				for (i in 0...FBRanges.members.length) {
					if (hitbox.overlaps(FBRanges.members[i], true)) {
						var closestDist:Float = 10;
						var closestDistX:Float = 10;
						for (j in 0...FBItems.members.length) {
							var dist:Float = Math.abs((FBItems.members[j].y + FBItems.members[j].height) - (FBRanges.members[i].y + FBRanges.members[i].height / 2));
							var distX:Float = Math.abs((FBItems.members[j].x + FBItems.members[j].width/2) - (FBRanges.members[i].x + FBRanges.members[i].width / 2));
							if (distX < closestDistX) {
								chosenObject = FBItems.members[j];
								closestDistX = distX;
							}
							if (dist < closestDist) {
								chosenObject = FBItems.members[j];
								closestDist = dist;
							}
						}
						break;
					}
				}
			case 'foreground':
				for (i in 0...FRanges.members.length) {
					if (hitbox.overlaps(FRanges.members[i], true)) {
						var closestDist:Float = 10;
						var closestDistX:Float = 10;
						for (j in 0...FItems.members.length) {
							var dist:Float = Math.abs((FItems.members[j].y + FItems.members[j].height) - (FRanges.members[i].y + FRanges.members[i].height / 2));
							var distX:Float = Math.abs((FItems.members[j].x + FItems.members[j].width/2) - (FRanges.members[i].x + FRanges.members[i].width / 2));
							if (distX < closestDistX) {
								chosenObject = FFItems.members[j];
								closestDistX = distX;
							}
							if (dist < closestDist) {
								chosenObject = FItems.members[j];
								closestDist = dist;
							}
						}
						break;
					}
				}
			case 'far foreground':
				for (i in 0...FFRanges.members.length) {
					if (hitbox.overlaps(FFRanges.members[i], true)) {
						var closestDist:Float = 10;
						var closestDistX:Float = 10;
						for (j in 0...FFItems.members.length) {
							var dist:Float = Math.abs((FFItems.members[j].y + FFItems.members[j].height) - (FFRanges.members[i].y + FFRanges.members[i].height / 2));
							var distX:Float = Math.abs((FFItems.members[j].x + FFItems.members[j].width/2) - (FFRanges.members[i].x + FFRanges.members[i].width / 2));
							if (distX < closestDistX) {
								chosenObject = FFItems.members[j];
								closestDistX = distX;
							}
							if (dist < closestDist) {
								chosenObject = FFItems.members[j];
								closestDist = dist;
							}
						}
						break;
					}
				}
		}

		if (chosenObject == null || chosenObject.pickedUp)
			chosenObject = "sus";
		else {
			add(marker);
			marker.x = chosenObject.x + chosenObject.width/2 - marker.width/2;
			marker.y = chosenObject.y - marker.height - 10;
			marker.scrollFactor.set(chosenObject.scrollFactor.x, chosenObject.scrollFactor.y);
			marker.animation.play('idle', true);
		}
	}

	var camFollow:FlxSprite = new FlxSprite(0, 0).makeGraphic(1,1, 0x00000000);
	var hitbox:FlxSprite = new FlxSprite(0, 0).makeGraphic(1,1, 0xffffffff);
	var sensor_left:FlxSprite = new FlxSprite(0, 0).makeGraphic(1,1, 0xffffffff);
	var sensor_right:FlxSprite = new FlxSprite(0, 0).makeGraphic(1,1, 0xffffffff);
	var sensor_up:FlxSprite = new FlxSprite(0, 0).makeGraphic(1,1, 0xffffffff);
	var sensor_down:FlxSprite = new FlxSprite(0, 0).makeGraphic(1,1, 0xffffffff);
	

	function createCharacter() {
		characterGroup.clear();

		characterGroup.x = 0;
		characterGroup.y = 0;

		camFollow.makeGraphic(1,1, 0x00000000);
		hitbox.makeGraphic(Std.int(RPGCharacter.hitboxWidth), Std.int(RPGCharacter.hitboxHeight), 0xffff0000);
		sensor_left.makeGraphic(Std.int(7), Std.int(RPGCharacter.hitboxHeight), 0xff00ff00);
		sensor_right.makeGraphic(Std.int(7), Std.int(RPGCharacter.hitboxHeight), 0xff0000ff);
		sensor_up.makeGraphic(Std.int(RPGCharacter.hitboxWidth), Std.int(7), 0xff00ffff);
		sensor_down.makeGraphic(Std.int(RPGCharacter.hitboxWidth), Std.int(7), 0xffff00ff);

		characterGroup.add(camFollow);
		characterGroup.add(hitbox);
		characterGroup.add(sensor_left);
		characterGroup.add(sensor_right);
		characterGroup.add(sensor_up);
		characterGroup.add(sensor_down);

        camCONTENT.follow(camFollow, LOCKON, 1);
	}

	function positionCharacter(object:Dynamic) {
		hitbox.setPosition(object.x + object.width/2 - hitbox.width/2, object.y + object.height - hitbox.height/2);
		sensor_left.setPosition(hitbox.x - sensor_left.width, hitbox.y);
		sensor_right.setPosition(hitbox.x + hitbox.width, hitbox.y);
		sensor_up.setPosition(hitbox.x, hitbox.y - sensor_up.height);
		sensor_down.setPosition(hitbox.x, hitbox.y + hitbox.height);

		charCont.setPosition(hitbox.x + hitbox.width/2, hitbox.y + hitbox.height/2);

		camFollow.setPosition(hitbox.x + hitbox.width/2 + RPGCharacter.cameraPosition[0], hitbox.y + hitbox.height/2 + RPGCharacter.cameraPosition[1]);
	}

	function dynamicPos(X:Float, Y:Float) {
		hitbox.setPosition(X - hitbox.width/2, Y - hitbox.height/2);
		sensor_left.setPosition(hitbox.x - sensor_left.width, hitbox.y);
		sensor_right.setPosition(hitbox.x + hitbox.width, hitbox.y);
		sensor_up.setPosition(hitbox.x, hitbox.y - sensor_up.height);
		sensor_down.setPosition(hitbox.x, hitbox.y + hitbox.height);

		RPGCharacter.x = hitbox.x + hitbox.width / 2 + RPGCharacter.positionArray[0];
		RPGCharacter.y = hitbox.y + hitbox.height / 2 + RPGCharacter.positionArray[1];

		camFollow.setPosition(hitbox.x + hitbox.width/2 + RPGCharacter.cameraPosition[0], hitbox.y + hitbox.height/2 + RPGCharacter.cameraPosition[1]);
	}

	var detailsText:String = "";
	var pausedDetailsText:String = "";

    function createWorld() {
		Paths.clearStoredMemory();
        //Music
		if (curMusic != AREA.music) {
        	FlxG.sound.playMusic(Paths.music('RPGMusic/'+AREA.music), 0.6, true);
			curMusic = AREA.music;
		}

		//Character
		if (curCharacter != AREA.character || curCharacter == "") {
			curCharacter = AREA.character;
			RPGCharacter = new RPGCharacter(0, 0, curCharacter);
			createCharacter();
		}

        //Zoom
        camCONTENT.zoom = AREA.cameraZoom;

        //Bounds
        camCONTENT.setScrollBounds(AREA.cameraBounds[0] - FlxG.width/2, AREA.cameraBounds[1] - FlxG.width/2, AREA.cameraBounds[2] - FlxG.height/2, AREA.cameraBounds[3] - FlxG.height/2);

        //Skybox
		if (curSkybox != AREA.skybox) {
			if(Paths.fileExists('images/' + 'skyboxes/'+AREA.skybox + '.txt', TEXT)) {
				skybox.frames = Paths.getPackerAtlas('skyboxes/'+AREA.skybox);
			} else {
				skybox.frames = Paths.getSparrowAtlas('skyboxes/'+AREA.skybox);
			}
			skybox.animation.addByPrefix('idle', "loop", 24);
			skybox.animation.play('idle');
			curSkybox = AREA.skybox;
			skybox.scrollFactor.set();
			skybox.screenCenter();
		}

        //Spawn Objects
        setLayerFactors();

        spawnAll();

        //First Time Dialogue
        if (AREA.firstDialogue != '' && !usedDialogue.contains(AREA.name)) {
            var file:String = Paths.json('RPG_Dialogue/' + AREA.firstDialogue); //Checks for json/Psych Engine dialogue
            dialogueJson = DialogueBoxPsych.parseDialogue(file);
            startDialogue(dialogueJson);
			usedDialogue.push(AREA.name);
        }

		#if desktop
		detailsText = "Exploring: " + AREA.name;
		pausedDetailsText = "Paused - " + AREA.name;

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, "As: " + curCharacter, null);
		#end

		worldGenerated = true;
		Paths.clearUnusedMemory();
    }

	function setLayerFactors() {
		FBItems.scrollFactor.set(AREA.content.f_background.scrollFactorX, AREA.content.f_background.scrollFactorY);
        BItems.scrollFactor.set(AREA.content.background.scrollFactorX, AREA.content.background.scrollFactorY);
        MItems.scrollFactor.set(AREA.content.middle.scrollFactorX, AREA.content.middle.scrollFactorY);
        FItems.scrollFactor.set(AREA.content.foreground.scrollFactorX, AREA.content.foreground.scrollFactorY);
        FFItems.scrollFactor.set(AREA.content.f_foreground.scrollFactorX, AREA.content.f_foreground.scrollFactorY);

		FBRanges.scrollFactor.set(AREA.content.f_background.scrollFactorX, AREA.content.f_background.scrollFactorY);
        BRanges.scrollFactor.set(AREA.content.background.scrollFactorX, AREA.content.background.scrollFactorY);
        MRanges.scrollFactor.set(AREA.content.middle.scrollFactorX, AREA.content.middle.scrollFactorY);
        FRanges.scrollFactor.set(AREA.content.foreground.scrollFactorX, AREA.content.foreground.scrollFactorY);
        FFRanges.scrollFactor.set(AREA.content.f_foreground.scrollFactorX, AREA.content.f_foreground.scrollFactorY);

		FBExits.scrollFactor.set(AREA.content.f_background.scrollFactorX, AREA.content.f_background.scrollFactorY);
		BExits.scrollFactor.set(AREA.content.background.scrollFactorX, AREA.content.background.scrollFactorY);
		MExits.scrollFactor.set(AREA.content.middle.scrollFactorX, AREA.content.middle.scrollFactorY);
		FExits.scrollFactor.set(AREA.content.foreground.scrollFactorX, AREA.content.foreground.scrollFactorY);
		FFExits.scrollFactor.set(AREA.content.f_foreground.scrollFactorX, AREA.content.f_foreground.scrollFactorY);

		FBCollision.scrollFactor.set(AREA.content.f_background.scrollFactorX, AREA.content.f_background.scrollFactorY);
		BCollision.scrollFactor.set(AREA.content.background.scrollFactorX, AREA.content.background.scrollFactorY);
		MCollision.scrollFactor.set(AREA.content.middle.scrollFactorX, AREA.content.middle.scrollFactorY);
		FCollision.scrollFactor.set(AREA.content.foreground.scrollFactorX, AREA.content.foreground.scrollFactorY);
		FFCollision.scrollFactor.set(AREA.content.f_foreground.scrollFactorX, AREA.content.f_foreground.scrollFactorY);
	}

    function spawnAll() {
        for (object in AREA.content.f_foreground.objects)
			spawnObject(object.type, object.layer, object);
		sortLayer('far foreground');

		for (object in AREA.content.foreground.objects)
			spawnObject(object.type, object.layer, object);
		sortLayer('foreground');

		for (object in AREA.content.middle.objects)
			spawnObject(object.type, object.layer, object);
		sortLayer('middle');

		for (object in AREA.content.background.objects)
			spawnObject(object.type, object.layer, object);
		sortLayer('background');

		for (object in AREA.content.f_background.objects)
			spawnObject(object.type, object.layer, object);
		sortLayer('far background');
    }

    function spawnObject(type:String, layer:String, ?existingFile:Dynamic = null, ?push:Bool = false) {

		var BasicDefs:BasicObjectValues;

		BasicDefs = existingFile;

		if (BasicDefs.type == 'Item' && usedItems.contains(AREA.name + '_' + BasicDefs.name)) {
			return;
		}

		if (BasicDefs.type == 'Object' && objectsToRemove.contains(AREA.name + '_' + BasicDefs.name)) {
			return;
		}

		exampleObject = new RPGObject(BasicDefs.posX, BasicDefs.posY);

		if (type == 'Spawn' || type == 'Exit') {
			exampleObject.loadGraphic(Paths.image(BasicDefs.imagePath));
		} else {
			if(Paths.fileExists('images/' + BasicDefs.imagePath + '.txt', TEXT)) {
				exampleObject.frames = Paths.getPackerAtlas(BasicDefs.imagePath);
			} else {
				exampleObject.frames = Paths.getSparrowAtlas(BasicDefs.imagePath);
			}
			exampleObject.frames = Paths.getSparrowAtlas(BasicDefs.imagePath);
			exampleObject.animation.addByPrefix('idle', 'loop', 24, true);
			exampleObject.animation.play('idle');
		}

		exampleObject.antialiasing = BasicDefs.antialiasingBool == true ? ClientPrefs.globalAntialiasing : false;
		exampleObject.alpha = BasicDefs.alphaNumber;
		exampleObject.angle = BasicDefs.angleNumber;
		exampleObject.flipX = BasicDefs.xFlip;
		exampleObject.flipY = BasicDefs.yFlip;
		exampleObject.visible =  BasicDefs.visible;
		exampleObject.scale.set(BasicDefs.scaleX, BasicDefs.scaleY);
		exampleObject.updateHitbox();
		exampleObject.name = BasicDefs.name;
		exampleObject.type = BasicDefs.type;
		exampleObject.imagePath = BasicDefs.imagePath;

		if (type == 'Spawn' && curExit == BasicDefs.specialValues.fromExit) {
			curLayer = BasicDefs.layer;
			
			positionCharacter(exampleObject);

			switch (curLayer) {
				case 'far background':
					FBItems.add(RPGCharacter);
				case 'background':
					BItems.add(RPGCharacter);
				case 'middle':
					MItems.add(RPGCharacter);
				case 'foreground':
					FItems.add(RPGCharacter);
				case 'far foreground':
					FFItems.add(RPGCharacter);
			}

			RPGCharacter.x = hitbox.x + hitbox.width / 2 + RPGCharacter.positionArray[0];
			RPGCharacter.y = hitbox.y + hitbox.height / 2 + RPGCharacter.positionArray[1];
		}

		switch (type) {
			case 'Spawn':
				exampleObject.fromExit = BasicDefs.specialValues.fromExit;
			case 'Exit':
				exampleObject.leadsToState = BasicDefs.specialValues.leadsToState;
				exampleObject.destination = BasicDefs.specialValues.destination;
				exampleObject.firstExitDialogue = BasicDefs.specialValues.firstExitDialogue;
				exampleObject.exitSound = BasicDefs.specialValues.exitSound;
			case 'Item':
				exampleObject.hasInteraction = BasicDefs.specialValues.hasInteraction;
				exampleObject.interactionRange = BasicDefs.specialValues.interactionRange;
				exampleObject.interactDialogue = BasicDefs.specialValues.interactDialogue;
			case 'Object':
				exampleObject.collisionPath = BasicDefs.specialValues.collisionPath;
				exampleObject.hasInteraction = BasicDefs.specialValues.hasInteraction;
				exampleObject.interactionRange = BasicDefs.specialValues.interactionRange;
				exampleObject.requiredItems = BasicDefs.specialValues.requiredItems;
				exampleObject.exactOrder = BasicDefs.specialValues.exactOrder;
				exampleObject.firstDialogue = BasicDefs.specialValues.firstDialogue;
				exampleObject.interactDialogue = BasicDefs.specialValues.interactDialogue;
				exampleObject.changeSprites = BasicDefs.specialValues.changeSprites;
				exampleObject.wrongDialogue = BasicDefs.specialValues.wrongDialogue;
				exampleObject.rightDialogue = BasicDefs.specialValues.rightDialogue;
				exampleObject.allDialogue = BasicDefs.specialValues.allDialogue;
				exampleObject.action = BasicDefs.specialValues.action;
				exampleObject.extraValue = BasicDefs.specialValues.extraValue;
			case 'NPC':
				exampleObject.hasInteraction = BasicDefs.specialValues.hasInteraction;
				exampleObject.interactionRange = BasicDefs.specialValues.interactionRange;
				exampleObject.requiredItems = BasicDefs.specialValues.requiredItems;
				exampleObject.exactOrder = BasicDefs.specialValues.exactOrder;
				exampleObject.firstDialogue = BasicDefs.specialValues.firstDialogue;
				exampleObject.interactDialogue = BasicDefs.specialValues.interactDialogue;
				exampleObject.changeSprites = BasicDefs.specialValues.changeSprites;
				exampleObject.wrongDialogue = BasicDefs.specialValues.wrongDialogue;
				exampleObject.rightDialogue = BasicDefs.specialValues.rightDialogue;
				exampleObject.allDialogue = BasicDefs.specialValues.allDialogue;
				exampleObject.action = BasicDefs.specialValues.action;
				exampleObject.extraValue = BasicDefs.specialValues.extraValue;
		}

		if (BasicDefs.type == 'Item' || BasicDefs.specialValues.hasInteraction) {
			var interactionEllipse:FlxSprite = new FlxSprite().makeGraphic(256, 256, FlxColor.TRANSPARENT);
			FlxSpriteUtil.drawEllipse(interactionEllipse, 0, 0, 256, 256, 0xFF0055FF);
			interactionEllipse.setGraphicSize(BasicDefs.specialValues.interactionRange, Std.int(BasicDefs.specialValues.interactionRange / 7 * 3));
			interactionEllipse.updateHitbox();
			interactionEllipse.x = exampleObject.x + exampleObject.width / 2 - interactionEllipse.width / 2;
			interactionEllipse.y = exampleObject.y + exampleObject.height - interactionEllipse.height / 2;
			interactionEllipse.antialiasing = ClientPrefs.globalAntialiasing;

			//add it to a certain group dependant on BasicDefs.layer
			if (BasicDefs.layer == 'far foreground') {
				FFRanges.add(interactionEllipse);
			} else if (BasicDefs.layer == 'foreground') {
				FRanges.add(interactionEllipse);
			} else if (BasicDefs.layer == 'middle') {
				MRanges.add(interactionEllipse);
			} else if (BasicDefs.layer == 'background') {
				BRanges.add(interactionEllipse);
			} else if (BasicDefs.layer == 'far background') {
				FBRanges.add(interactionEllipse);
			}
		}

		if (BasicDefs.specialValues.collisionPath != '' && BasicDefs.specialValues.collisionPath != null) {
			var canLoad:Bool = true;

			if (BasicDefs.type == 'Object') {
				if(!Paths.fileExists('images/' + BasicDefs.specialValues.collisionPath + '_Collision.png', IMAGE)) canLoad = false;
			}

			if (canLoad) {
				var collision:RPGCollision = new RPGCollision(0, 0);

				if(Paths.fileExists('images/' + BasicDefs.specialValues.collisionPath + '_Collision.txt', TEXT)) {
					collision.frames = Paths.getPackerAtlas(BasicDefs.specialValues.collisionPath + '_Collision');
				} else {
					collision.frames = Paths.getSparrowAtlas(BasicDefs.specialValues.collisionPath + '_Collision');
				}
				collision.animation.addByPrefix('idle', "loop", 24);
				collision.animation.play('idle');

				collision.scale.x = exampleObject.scale.x;
				collision.scale.y = exampleObject.scale.y;
				collision.updateHitbox();
				collision.x = exampleObject.x;
				collision.y = exampleObject.y;
				collision.angle = exampleObject.angle;
				collision.flipX = exampleObject.flipX;
				collision.flipY = exampleObject.flipY;
				collision.antialiasing = exampleObject.antialiasing;

				collision.belongsTo = exampleObject.name;

				if (BasicDefs.layer == 'far foreground') {
					FFCollision.add(collision);
				} else if (BasicDefs.layer == 'foreground') {
					FCollision.add(collision);
				} else if (BasicDefs.layer == 'middle') {
					MCollision.add(collision);
				} else if (BasicDefs.layer == 'background') {
					BCollision.add(collision);
				} else if (BasicDefs.layer == 'far background') {
					FBCollision.add(collision);
				}
			}
		}

		if (BasicDefs.type == 'Spawn') {
			return;
		}

		switch (layer) {
			case 'far foreground':
				if (type == 'Exit') {
					FFExits.add(exampleObject);
				} else {
					FFItems.add(exampleObject);
				}
			case 'foreground':
				if (type == 'Exit') {
					FExits.add(exampleObject);
				} else {
					FItems.add(exampleObject);
				}
			case 'middle':
				if (type == 'Exit') {
					MExits.add(exampleObject);
				} else {
					MItems.add(exampleObject);
				}
			case 'background':
				if (type == 'Exit') {
					BExits.add(exampleObject);
				} else {
					BItems.add(exampleObject);
				}
			case 'far background':
				if (type == 'Exit') {
					FBExits.add(exampleObject);
				} else {
					FBItems.add(exampleObject);
				}
		}
	}

	public static inline function sortByYPlusHeight(Order:Int, Obj1:FlxObject, Obj2:FlxObject):Int
	{
		return FlxSort.byValues(Order, Obj1.y + Obj1.height, Obj2.y + Obj2.height);
	}

	function sortLayer(layer:String) {
		switch (layer) {
			case 'far foreground':
				FFItems.sort(sortByYPlusHeight);
			case 'foreground':
				FItems.sort(sortByYPlusHeight);
			case 'middle':
				MItems.sort(sortByYPlusHeight);
			case 'background':
				BItems.sort(sortByYPlusHeight);
			case 'far background':
				FBItems.sort(sortByYPlusHeight);
		}
	}

	public var psychDialogue:DialogueBoxPsych;
	public function startDialogue(dialogueFile:DialogueFile, ?action:String = null):Void
	{
		// TO DO: Make this more flexible, maybe?
		if(psychDialogue != null) return;

		if(dialogueFile.dialogue.length > 0) {
			inCutscene = true;
			CoolUtil.precacheSound('dialogue');
			CoolUtil.precacheSound('dialogueClose');
			psychDialogue = new DialogueBoxPsych(dialogueFile, null, false);
			psychDialogue.scrollFactor.set();
			switch (action) {
				default:
					psychDialogue.finishThing = dialogueEnd;
				case 'transition':
					psychDialogue.finishThing = roomTransition;
				case 'action':
					psychDialogue.finishThing = proceedWithAction;
			}
			add(psychDialogue);
		} else {
			FlxG.log.warn('Your dialogue file is badly formatted!');
			dialogueEnd();
		}
	}
	
	public function dialogueEnd() {
		inCutscene = false;
	}
	
	public function roomTransition() {
		inCutscene = false;

		if (destination_exit != '') {
			if (leadsToState) {
				FlxTransitionableState.skipNextTransIn = false;
				CustomFadeTransition.nextCamera = camHUD;
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				if (exitSound != '')
					FlxG.sound.play(Paths.sound(exitSound));

				switch (destination_exit) {
					case 'Title':
						RPGAreaState.switchState(new TitleState());
					case 'Story':
						RPGAreaState.switchState(new StoryMenuState());
					case 'Freeplay':
						RPGAreaState.switchState(new FreeplayState());
					case 'Credits':
						RPGAreaState.switchState(new CreditsState());
					default:
						RPGAreaState.switchState(new MainMenuState());
				}
			} else {
				AREA = RPGAreas.loadFromJson(destination_exit);
				if (exitSound != '')
					FlxG.sound.play(Paths.sound(exitSound));
	
				curExit = destination_exit;

				keyboardMoving = false;
				mouseMoving = false;

				TransitionRoom();
			}
		}
	}

	public function proceedWithAction() {
		if ((chosenObject.action.toLowerCase() != 'play sound' && chosenObject.action.toLowerCase() != 'send to area'
		&& chosenObject.action.toLowerCase() != 'send to state' && chosenObject.action.toLowerCase() != 'send to song')
		&& !finishedObjects.contains(AREA.name + '_' + chosenObject.name))
			finishedObjects.push(AREA.name + '_' + chosenObject.name);

		if (chosenObject.extraValue != '') {
			switch (chosenObject.action.toLowerCase()) {
				case 'play sound':
					FlxG.sound.play(Paths.sound(chosenObject.extraValue));
				case 'send to state':
					switch (chosenObject.extraValue) {
						case 'Title':
							RPGAreaState.switchState(new TitleState());
						case 'Story':
							RPGAreaState.switchState(new StoryMenuState());
						case 'Freeplay':
							RPGAreaState.switchState(new FreeplayState());
						case 'Credits':
							RPGAreaState.switchState(new CreditsState());
						default:
							RPGAreaState.switchState(new MainMenuState());
					}
				case 'send to area':
					AREA = RPGAreas.loadFromJson(chosenObject.extraValue);
					curExit = '';

					TransitionRoom();
				case 'send to song':
					curExit = chosenObject.extraValue;
					PlayState.cameFromRPG = true;
					var difficulty = '' + CoolUtil.getDifficultyFilePath(PlayState.storyDifficulty);
					PlayState.SONG = Song.loadFromJson(chosenObject.extraValue + difficulty, chosenObject.extraValue);
					LoadingState.loadAndSwitchState(new PlayState(), true, true);
				case 'give item':
					chosenObject.pickedUp = true;
					FlxG.sound.play(Paths.sound('ItemAccept'));
					var item = {
						name: chosenObject.extraValue,
						imagePath: 'objects/' + chosenObject.extraValue,
					}
					currentItems.push(item);

					var itemImage = new FlxSprite(0,0);
					if(Paths.fileExists('images/' + item.imagePath + '.txt', TEXT)) {
						itemImage.frames = Paths.getPackerAtlas(item.imagePath);
					} else {
						itemImage.frames = Paths.getSparrowAtlas(item.imagePath);
					}
					itemImage.animation.addByPrefix('idle', 'loop', 24, true);
					itemImage.animation.play('idle');

					itemImage.antialiasing = ClientPrefs.globalAntialiasing;
					itemImage.setGraphicSize(45, 0);
					itemImage.updateHitbox();
					if (itemImage.height > 45) {
						itemImage.setGraphicSize(0, 45);
						itemImage.updateHitbox();
					}

					itemImage.x = inventorySprite.width / 2 - itemImage.width / 2;
					itemImage.y = 62 + ((inventoryGroup.length - 1) * (52.75)) - itemImage.height / 2;

					inventoryGroup.add(itemImage);
				case 'remove':
					chosenObject.pickedUp = true;
					chosenObject.visible = false;

					//now for collisions
					switch (curLayer) {
						case 'middle':
							for (i in 0...MCollision.members.length) {
								if (MCollision.members[i].belongsTo = chosenObject.name) {
									MCollision.remove(MCollision.members[i]);
									break;
								}
							}
						case 'background':
							for (i in 0...BCollision.members.length) {
								if (BCollision.members[i].belongsTo = chosenObject.name) {
									BCollision.remove(BCollision.members[i]);
									break;
								}
							}
						case 'foreground':
							for (i in 0...FCollision.members.length) {
								if (FCollision.members[i].belongsTo = chosenObject.name) {
									FCollision.remove(FCollision.members[i]);
									break;
								}
							}
						case 'far background':
							for (i in 0...FBCollision.members.length) {
								if (FBCollision.members[i].belongsTo = chosenObject.name) {
									FBCollision.remove(FBCollision.members[i]);
									break;
								}
							}
						case 'far foreground':
							for (i in 0...FFCollision.members.length) {
								if (FFCollision.members[i].belongsTo = chosenObject.name) {
									FFCollision.remove(FFCollision.members[i]);
									break;
								}
							}
					}

					remove(marker);
					objectsToRemove.push(AREA.name + '_' + chosenObject.name);
					chosenObject = null;
				case 'grant achievement':
					chosenObject.pickedUp = true;
					if(!Achievements.isAchievementUnlocked(chosenObject.extraValue)) {
						Achievements.unlockAchievement(chosenObject.extraValue);
					}
				case 'trigger curscene': //this is gonna be hardcoded dw
			}
		}
	}

	function TransitionRoom() {
		transitioning = true;

		camHUD.fade(FlxColor.BLACK, 0.5, false, function()
		{
			worldGenerated = false;

			//clear all FlxTypedSpriteGroups
			FRanges.clear();
			MRanges.clear();
			BRanges.clear();
			FBRanges.clear();
			FFRanges.clear();

			FExits.clear();
			MExits.clear();
			BExits.clear();
			FBExits.clear();
			FFExits.clear();

			FItems.clear();
			MItems.clear();
			BItems.clear();
			FBItems.clear();
			FFItems.clear();

			FCollision.clear();
			MCollision.clear();
			BCollision.clear();
			FBCollision.clear();
			FFCollision.clear();

			createWorld();

			camHUD.fade(FlxColor.BLACK, 0.5, true, function()
			{
				transitioning = false;
			});
		});
	}

	function animationHandler(action:String) {
		//angles
		if (action != 'stand') {
			if (xChange > 0) {
				if (yChange < 0) {
					angleHandler = 'URIGHT';
				} else if (yChange > 0) {
					angleHandler = 'DRIGHT';
				} else {
					angleHandler = 'RIGHT';
				}
			} else if (xChange < 0) {
				if (yChange < 0) {
					angleHandler = 'ULEFT';
				} else if (yChange > 0) {
					angleHandler = 'DLEFT';
				} else {
					angleHandler = 'LEFT';
				}
			} else {
				if (yChange < 0) {
					angleHandler = 'UP';
				} else if (yChange > 0) {
					angleHandler = 'DOWN';
				}
			}
		}

		//animations
		switch (action) {
			case 'stand':
				if (characterIdleTimer > 0) {
					characterIdleTimer -= FlxG.elapsed;
					if (!RPGCharacter.animation.curAnim.name.contains('stand-${angleHandler}'))
						RPGCharacter.playAnim('stand-${angleHandler}', true);
				} else {
					if (!RPGCharacter.animation.curAnim.name.contains('idle-${angleHandler}'))
						RPGCharacter.playAnim('idle-${angleHandler}', true);
				}
			case 'walk':
				if (RPGCharacter.animation.curAnim.name.contains('stand') || RPGCharacter.animation.curAnim.name.contains('idle')) {
					frameHandler = -1;
				}
				if (RPGCharacter.animation.curAnim.name.contains('run')) {
					frameHandler *= 2;
				}
				if (!RPGCharacter.animation.curAnim.name.contains('walk-${angleHandler}')) {
					RPGCharacter.playAnim('walk-${angleHandler}', true);
					RPGCharacter.animation.curAnim.curFrame = frameHandler + 1;
					if (frameHandler + 1 > RPGCharacter.animation.curAnim.frames.length - 1) {
						RPGCharacter.animation.curAnim.curFrame = 0;
					}
				}
				frameHandler = RPGCharacter.animation.curAnim.curFrame;
			case 'run':
				if (RPGCharacter.animation.curAnim.name.contains('stand') || RPGCharacter.animation.curAnim.name.contains('idle')) {
					frameHandler = -1;
				}
				if (RPGCharacter.animation.curAnim.name.contains('walk')) {
					frameHandler = Math.round(frameHandler / 2);
				}
				if (!RPGCharacter.animation.curAnim.name.contains('run-${angleHandler}')) {
					RPGCharacter.playAnim('run-${angleHandler}', true);
					RPGCharacter.animation.curAnim.curFrame = frameHandler;
					if (frameHandler > RPGCharacter.animation.curAnim.frames.length - 1) {
						RPGCharacter.animation.curAnim.curFrame = 0;
					}
				}
				frameHandler = RPGCharacter.animation.curAnim.curFrame;
		}
	}

	var xChange:Float = 0;
	var yChange:Float = 0;
}