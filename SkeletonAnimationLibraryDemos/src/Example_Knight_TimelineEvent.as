package  
{
	import flash.display.Sprite;

	import starling.core.Starling;

    [SWF(width="800", height="600", frameRate="60", backgroundColor="#cccccc")]
	public class Example_Knight_TimelineEvent extends flash.display.Sprite 
	{
		public function Example_Knight_TimelineEvent() 
		{
			starlingInit();
		}

		private function starlingInit():void 
		{
			var starling:Starling = new Starling(StarlingGame, stage);
			starling.showStats = true;
			starling.start();
		}
	}
}

import flash.geom.Point;

import starling.core.Starling;
import starling.textures.Texture;
import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.KeyboardEvent;
import starling.events.TouchEvent;
import starling.events.Touch;
import starling.events.TouchPhase;
import starling.events.Event;

import starling.text.TextField;

import starling.extensions.PDParticleSystem;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.Slot;
import dragonBones.animation.WorldClock;
import dragonBones.factorys.StarlingFactory;
import dragonBones.objects.DataParser;
import dragonBones.objects.SkeletonData;
import dragonBones.textures.StarlingTextureAtlas;

import dragonBones.display.StarlingDisplayBridge;

import dragonBones.events.AnimationEvent;
import dragonBones.events.FrameEvent;

class StarlingGame extends Sprite 
{
	[Embed(source = "../assets/Knight/skeleton.json", mimeType = "application/octet-stream")]
	public static const SkeletonJSONData:Class;
	
	[Embed(source = "../assets/Knight/texture.png")]
	public static const TextureData:Class;
	
	[Embed(source = "../assets/Knight/texture.json", mimeType = "application/octet-stream")]
	public static const TextureJSONData:Class;
	
	[Embed(source = "../assets/particles/particle.pex", mimeType = "application/octet-stream")]
	private static const ParticleCFG:Class;
 
	[Embed(source = "../assets/particles/texture.png")]
	private static const ParticleImage:Class;

	private var _factory:StarlingFactory;
	private var _armature:Armature;
	private var _armatureDisplay:Sprite;
	
	private var _arm:Bone;
	
	private var _textField:TextField;

	public function StarlingGame() 
	{
		_factory = new StarlingFactory();
		
		var skeletonData:SkeletonData = DataParser.parseData(JSON.parse(new SkeletonJSONData()));
		_factory.addSkeletonData(skeletonData, "knightSkeleton");
		
		var textureAtlas:StarlingTextureAtlas = new StarlingTextureAtlas(
			Texture.fromBitmapData(new TextureData().bitmapData, false, false, 1), 
			JSON.parse(new TextureJSONData())
		);
		_factory.addTextureAtlas(textureAtlas, "knightSkeleton");
		
		this.addEventListener(Event.ADDED_TO_STAGE, addToStageHandler);
	}
	
	private function addToStageHandler(e:Event):void
	{
		_armature = _factory.buildArmature("knight");
		_armatureDisplay = _armature.display as Sprite;
		_armatureDisplay.x = 400;
		_armatureDisplay.y = 400;
		
		this.addChild(_armatureDisplay);
		WorldClock.clock.add(_armature);
		updateMovement();
		
		_arm = _armature.getBone("armOutside");
		_arm.childArmature.addEventListener(AnimationEvent.MOVEMENT_CHANGE, armMovementHandler);
		_arm.childArmature.addEventListener(AnimationEvent.COMPLETE, armMovementHandler);
		_arm.childArmature.addEventListener(FrameEvent.MOVEMENT_FRAME_EVENT, armFrameEventHandler);
		
		initParticles();
		
		this.addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrameHandler);

		stage.addEventListener(KeyboardEvent.KEY_DOWN, keyEventHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, keyEventHandler);
		stage.addEventListener(TouchEvent.TOUCH, touchHandler);
		
		_textField = new TextField(700, 30, "Press W/A/D to move. Press S to upgrade weapon.\nPress SPACE to switch weapens. Click mouse to attack.", "Verdana", 16, 0, true)
		_textField.height = 40;
		_textField.x = 60;
		_textField.y = 5;
		this.addChild(_textField);
	}
	
	private function initParticles():void
	{
		var horseHead:Bone = _armature.getBone("horseHead");
		var horseEye:Bone = horseHead.childArmature.getBone("eye");
		
		var exhaust:PDParticleSystem = new PDParticleSystem(new XML(new ParticleCFG()), Texture.fromBitmap(new ParticleImage()));
		var particle:Slot = new Slot(new StarlingDisplayBridge());
		particle.fixedRotation = true;
		particle.display = exhaust;
		particle.origin.x = horseEye.global.x;
		particle.origin.y = horseEye.global.y;
		
		particle.zOrder = 100;
		
		horseHead.addChild(particle);
		exhaust.start();
		Starling.juggler.add(exhaust);
	}

	private function enterFrameHandler(e:EnterFrameEvent):void 
	{
		updateSpeed();
		WorldClock.clock.advanceTime(-1);
		updateArrows();
	}

	private function keyEventHandler(e:KeyboardEvent):void 
	{
		switch (e.keyCode) 
		{
			case 37 :
			case 65 :
				_isLeftDown = e.type == KeyboardEvent.KEY_DOWN;
				move(-1);
				break;
			case 39 :
			case 68 :
				_isRightDown = e.type == KeyboardEvent.KEY_DOWN;
				move(1);
				break;
			case 38 :
			case 87 :
				if (e.type == KeyboardEvent.KEY_DOWN) 
				{
					jump();
				}
				break;
			case 83 :
			case 40 :
				if (e.type == KeyboardEvent.KEY_DOWN) 
				{
					upgradeWeapon();
				}
				break;
			case 32 :
				if (e.type == KeyboardEvent.KEY_UP) 
				{
					changeWeapon();
				}
				break;
		}
	}
	
	private function touchHandler(event:TouchEvent):void
	{
		var touch:Touch = event.getTouch(stage);
		if(touch)
		{
			if(touch.phase == TouchPhase.BEGAN)
			{
				attack();
			}
		}
	}

	private var _isJumping:Boolean;
	private var _isLeftDown:Boolean;
	private var _isRightDown:Boolean;
	private var _moveDir:int;

	private var _speedX:Number = 0;
	private var _speedY:Number = 0;

	private function move(dir:int):void 
	{
		if (_isLeftDown && _isRightDown) 
		{
		}
		else if (_isLeftDown)
		{
			dir = -1;
		}
		else if (_isRightDown)
		{
			dir = 1;
		}
		else 
		{
			dir = 0;
		}
	
		if (_moveDir == dir) 
		{
			return;
		}
		_moveDir = dir;
		updateMovement();
	}

	private function jump():void 
	{
		if (_isJumping) 
		{
			return;
		}
		_speedY = -15;
		_isJumping = true;
		_armature.animation.gotoAndPlay("jump");
	}
	
	private const SWORD:String = "sword";
	private const PIKE:String = "pike";
	private const AXE:String = "axe";
	private const BOW:String = "bow";
	private const WEAPON_NAMES:Array = [SWORD, PIKE, AXE, BOW];
	private var _weaponID:int = 0;
	private function changeWeapon():void 
	{
		_weaponID ++;
		if (_weaponID >= 4) 
		{
			_weaponID -= 4;
		}

		var weaponName:String = WEAPON_NAMES[_weaponID];
		var movementName:String = "ready_" + weaponName;

		_arm.childArmature.animation.gotoAndPlay(movementName);
	}

	private var _weaponLevels:Vector.<int> = new <int>[0, 0, 0, 0];
	private function upgradeWeapon():void
	{
		var weaponLevel:int = _weaponLevels[_weaponID];
		weaponLevel ++;
		if (weaponLevel >= 3) 
		{
			weaponLevel -= 3;
		}
		_weaponLevels[_weaponID] = weaponLevel;
		
		var weaponName:String = WEAPON_NAMES[_weaponID];
		switch(weaponName)
		{
			case SWORD:
			case PIKE:
			case AXE:
				var weapon:Bone = _arm.childArmature.getBone("weapon");
				
				weapon.display.dispose();
				weapon.display = _factory.getTextureDisplay("knightFolder/" + weaponName + "_" + (weaponLevel + 1)) as Image;
				break;
			case BOW:
				var bow:Bone = _arm.childArmature.getBone("bow");
				
				var bowBA:Bone = bow.childArmature.getBone("ba");
				var bowBB:Bone = bow.childArmature.getBone("bb");
				var bowArrow:Bone = bow.childArmature.getBone("arrow");
				var bowArrowB:Bone = bow.childArmature.getBone("arrowBackup");
				
				bowBA.display.dispose();
				bowBB.display.dispose();
				bowArrow.display.dispose();
				bowArrowB.display.dispose();
				bowBA.display = _factory.getTextureDisplay("knightFolder/" + weaponName + "_" + (weaponLevel + 1)) as Image;
				bowBB.display = _factory.getTextureDisplay("knightFolder/" + weaponName + "_" + (weaponLevel + 1)) as Image;
				bowArrow.display = _factory.getTextureDisplay("knightFolder/arrow_" + (weaponLevel + 1)) as Image;
				bowArrowB.display = _factory.getTextureDisplay("knightFolder/arrow_" + (weaponLevel + 1)) as Image;
				break;
		}
	}

	private var _isAttacking:Boolean;
	private var _isComboAttack:Boolean;
	private var _hitCount:uint = 1;
	private function attack():void 
	{
		if (_isAttacking) 
		{
			return;
		}
		_isAttacking = true;
		var weaponName:String = WEAPON_NAMES[_weaponID];
		var movementName:String = "attack_" + weaponName + "_" + _hitCount;

		_arm.childArmature.animation.gotoAndPlay(movementName);
	}
	
	private function armMovementHandler(e:AnimationEvent):void 
	{
		switch(e.type)
		{
			case AnimationEvent.MOVEMENT_CHANGE:
				_isComboAttack = false;
				break;
			case AnimationEvent.COMPLETE:
				if(_isComboAttack)
				{
					var weaponName:String = WEAPON_NAMES[_weaponID];
					var movementName:String = "ready_" + weaponName;
					_arm.childArmature.animation.gotoAndPlay(movementName);
				}
				else
				{
					_isAttacking = false;
					_hitCount = 1;
					_isComboAttack = false;
				}
				break;
		}
	}

	private function armFrameEventHandler(e:FrameEvent):void 
	{
		switch(e.frameLabel)
		{
			case "fire":
				var bow:Bone = _arm.childArmature.getBone("bow");
				bow.display.localToGlobal(_localPoint, _resultPoint);
				if (_armatureDisplay.scaleX > 0) 
				{
					var r:Number = _armatureDisplay.rotation + bow.global.rotation;
				}
				else 
				{
					r = _armatureDisplay.rotation - bow.global.rotation + Math.PI;
				}
				
				switch(_weaponLevels[_weaponID])
				{
					case 0:
						createArrow(r, _resultPoint);
						break;
					case 1:
						createArrow(3 / 180 * Math.PI + r, _resultPoint);
						createArrow(-3 / 180 * Math.PI+ r, _resultPoint);
						break;
					case 2:
						createArrow(6 / 180 * Math.PI + r, _resultPoint);
						createArrow(r, _resultPoint);
						createArrow(-6 / 180 * Math.PI + r, _resultPoint);
						break;
				}
				
				trace("frameEvent:" + e.frameLabel);
				break;
			case "ready":
				_isAttacking = false;
				_isComboAttack = true;
				_hitCount ++;
				break;
		}
	}

	private var _arrows:Array = [];
	private var _localPoint:Point = new Point();
	private var _resultPoint:Point = new Point();
	private function createArrow(r:Number, point:Point):void 
	{
		var arrowDisplay:Image = _factory.getTextureDisplay("knightFolder/arrow_1") as Image;
		arrowDisplay.x = point.x;
		arrowDisplay.y = point.y;
		arrowDisplay.rotation = r;

		var vx:Number = Math.cos(r) * 36;
		var vy:Number = Math.sin(r) * 36;
		var arrow:Object = { display:arrowDisplay, vx:vx, vy:vy };
		_arrows.push(arrow);
		this.addChild(arrowDisplay);
	}

	private function updateArrows():void 
	{
		var arrow:Object;
		var length:uint = _arrows.length;
		for (var i:int = length - 1; i >= 0; i --) 
		{
			arrow = _arrows[i];
			arrow.vy += 1;
			arrow.display.x += arrow.vx;
			arrow.display.y += arrow.vy;
			arrow.display.rotation = Math.atan2(arrow.vy, arrow.vx);
			if (arrow.display.y > 850) 
			{
				_arrows.splice(i, 1);
				removeChild(arrow.display);
				arrow.display.dispose();
				arrow.display = null;
			}
		}
	}

	private function updateMovement():void 
	{
		if (_isJumping) 
		{
			return;
		}

		if (_moveDir == 0) 
		{
			_speedX = 0;
			_armature.animation.gotoAndPlay("stand");
		}
		else 
		{
			_speedX = _moveDir * 4;
			_armature.animation.gotoAndPlay("run");
			_armatureDisplay.scaleX = _moveDir;
		}
	}

	private function updateSpeed():void 
	{
		if (_isJumping) 
		{
			_speedY += 0.6;
		}

		if (_speedX != 0) 
		{
			_armatureDisplay.x += _speedX;
			if (_armatureDisplay.x < 0) 
			{
				_armatureDisplay.x = 0;
			}
			else if (_armatureDisplay.x > 800) 
			{
				_armatureDisplay.x = 800;
			}
		}

		if (_speedY != 0) 
		{
			_armatureDisplay.rotation = _speedY * 0.02 * _armatureDisplay.scaleX;
			_armatureDisplay.y += _speedY;
			if (_armatureDisplay.y > 400) 
			{
				_armatureDisplay.y = 400;
				_isJumping = false;
				_speedY = 0;
				_armatureDisplay.rotation = 0;
				updateMovement();
			}
		}
	}
}