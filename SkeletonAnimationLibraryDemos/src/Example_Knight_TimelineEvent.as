package  {
	import flash.display.Sprite;

	import starling.core.Starling;

    [SWF(width="800", height="600", frameRate="60", backgroundColor="#cccccc")]
	public class Example_Knight_TimelineEvent extends flash.display.Sprite {

		public function Example_Knight_TimelineEvent() {
			starlingInit();
		}

		private function starlingInit():void {
			var _starling:Starling = new Starling(StarlingGame, stage);
			//_starling.antiAliasing = 1;
			_starling.showStats = true;
			_starling.start();
		}
	}
}

import flash.geom.Point;
import flash.events.Event;

import starling.display.Image;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.KeyboardEvent;
import starling.events.TouchEvent;
import starling.events.Touch;
import starling.events.TouchPhase;

import starling.text.TextField;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.animation.WorldClock;
import dragonBones.factorys.StarlingFactory;

import dragonBones.events.AnimationEvent;
import dragonBones.events.FrameEvent;

class StarlingGame extends Sprite {
	[Embed(source = "../assets/Knight_output.swf", mimeType = "application/octet-stream")]
	public static const ResourcesData:Class;

	private var factory:StarlingFactory;
	private var armature:Armature;
	private var armatureDisplay:Sprite;
	
	private var arm:Bone;
	
	private var textField:TextField;

	public function StarlingGame() {
		factory = new StarlingFactory();
		factory.parseData(new ResourcesData());
		factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	}

	private function textureCompleteHandler(e:Event):void {
		armature = factory.buildArmature("knight");
		armatureDisplay = armature.display as Sprite;
		armatureDisplay.x = 400;
		armatureDisplay.y = 400;
		addChild(armatureDisplay);
		
		WorldClock.clock.add(armature);
		updateMovement();
		
		arm = armature.getBone("armOutside");
		arm.childArmature.addEventListener(AnimationEvent.MOVEMENT_CHANGE, armMovementHandler);
		arm.childArmature.addEventListener(AnimationEvent.COMPLETE, armMovementHandler);
		arm.childArmature.addEventListener(FrameEvent.MOVEMENT_FRAME_EVENT, armFrameEventHandler);
		
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);

		stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEventHandler);
		stage.addEventListener(KeyboardEvent.KEY_UP, onKeyEventHandler);
		stage.addEventListener(TouchEvent.TOUCH, onTouch);
		
		textField = new TextField(700, 30, "Press W/A/D to move. Press SPACE to switch weapens. Click mouse to attack.", "Verdana", 16, 0, true)
		textField.x = 60;
		textField.y = 5;
		addChild(textField);
	}

	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		updateSpeed();
		WorldClock.clock.advanceTime(-1);
		updateArrows();
	}

	private function onKeyEventHandler(e:KeyboardEvent):void {
		switch (e.keyCode) {
			case 37 :
			case 65 :
				left = e.type == KeyboardEvent.KEY_DOWN;
				move(-1);
				break;
			case 39 :
			case 68 :
				right = e.type == KeyboardEvent.KEY_DOWN;
				move(1);
				break;
			case 38 :
			case 87 :
				if (e.type == KeyboardEvent.KEY_DOWN) {
					jump();
				}
				break;
			case 32 :
				if (e.type == KeyboardEvent.KEY_UP) {
					changeWeapon();
				}
				break;
		}
	}
	
	private function onTouch(event:TouchEvent):void
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

	private var isJumping:Boolean;
	private var left:Boolean;
	private var right:Boolean;
	private var moveDir:int;

	private var speedX:Number = 0;
	private var speedY:Number = 0;

	public function move(_dir:int):void {
		if (left && right) {
		}else if (left){
			_dir = -1;
		}else if (right){
			_dir = 1;
		}else {
			_dir = 0;
		}
	
		if (moveDir == _dir) {
			return;
		}
		moveDir = _dir;
		updateMovement();
	}

	public function jump():void {
		if (isJumping) {
			return;
		}
		speedY = -15;
		isJumping = true;
		armature.animation.gotoAndPlay("jump");
	}

	private var weaponID:int = 0;
	private const weaponNames:Array = ["sword", "pike", "axe", "bow"];
	public function changeWeapon():void {
		weaponID ++;
		if (weaponID >= 4) {
			weaponID -= 4;
		}

		var _weaponName:String = weaponNames[weaponID];
		var _movementName:String = "ready_" + _weaponName;

		arm.childArmature.animation.gotoAndPlay(_movementName);
	}


	private var isAttacking:Boolean;
	private var isComboAttack:Boolean;
	private var hitCount:uint = 1;
	public function attack():void {
		if (isAttacking) {
			return;
		}
		isAttacking = true;
		var _weaponName:String = weaponNames[weaponID];
		var _movementName:String = "attack_" + _weaponName + "_" + hitCount;

		arm.childArmature.animation.gotoAndPlay(_movementName);
	}
	
	private function armMovementHandler(e:AnimationEvent):void 
	{
		switch(e.type)
		{
			case AnimationEvent.MOVEMENT_CHANGE:
				isComboAttack = false;
				break;
			case AnimationEvent.COMPLETE:
				if(isComboAttack)
				{
					var _weaponName:String = weaponNames[weaponID];
					var _movementName:String = "ready_" + _weaponName;
					arm.childArmature.animation.gotoAndPlay(_movementName);
				}
				else
				{
					isAttacking = false;
					hitCount = 1;
					isComboAttack = false;
				}
				break;
		}
	}

	private function armFrameEventHandler(e:FrameEvent):void 
	{
		switch(e.frameLabel)
		{
			case "fire":
				createArrow();
				trace("frameEvent:" + e.frameLabel);
				break;
			case "ready":
				isAttacking = false;
				isComboAttack = true;
				hitCount ++;
				break;
		}
	}

	private var arrows:Array = [];
	private var localPoint:Point = new Point();
	private var resultPoint:Point = new Point();
	private function createArrow():void {

		var _arrowDisplay:Image = factory.getTextureDisplay("knightFolder/arrow_1") as Image;
		var _bow:Bone = arm.childArmature.getBone("bow");
		_bow.display.localToGlobal(localPoint, resultPoint);

		var _r:Number;
		if (armatureDisplay.scaleX > 0) {
			_r = armatureDisplay.rotation + _bow.global.rotation;
		}else {
			_r = armatureDisplay.rotation - _bow.global.rotation + Math.PI;
		}

		_arrowDisplay.x = resultPoint.x;
		_arrowDisplay.y = resultPoint.y;
		_arrowDisplay.rotation = _r;

		var _vx:Number = Math.cos(_r) * 36;
		var _vy:Number = Math.sin(_r) * 36;
		var _arrow:Object = { display:_arrowDisplay, vx:_vx, vy:_vy };
		arrows.push(_arrow);
		addChild(_arrowDisplay);
	}

	private function updateArrows():void {
		var _arrow:Object;
		var _length:uint = arrows.length;
		for (var _i:int = _length - 1; _i >= 0; _i --) {
			_arrow = arrows[_i];
			_arrow.vy += 1;
			_arrow.display.x += _arrow.vx;
			_arrow.display.y += _arrow.vy;
			_arrow.display.rotation = Math.atan2(_arrow.vy, _arrow.vx);
			if (_arrow.display.y > 850) {
				arrows.splice(_i, 1);
				removeChild(_arrow.display);
				_arrow.display.dispose();
				_arrow.display = null;
			}
		}
	}

	private function updateMovement():void {
		if (isJumping) {
			return;
		}

		if (moveDir == 0) {
			speedX = 0;
			armature.animation.gotoAndPlay("stand");
		}else {
			speedX = moveDir * 4;
			armature.animation.gotoAndPlay("run");
			armatureDisplay.scaleX = moveDir;
		}
	}

	private function updateSpeed():void {
		if (isJumping) {
			speedY += 0.6;
		}

		if (speedX != 0) {
			armatureDisplay.x += speedX;
			if (armatureDisplay.x < 0) {
				armatureDisplay.x = 0;
			}else if (armatureDisplay.x > 800) {
				armatureDisplay.x = 800;
			}
		}

		if (speedY != 0) {
			armatureDisplay.rotation = speedY * 0.02 * armatureDisplay.scaleX;
			armatureDisplay.y += speedY;
			if (armatureDisplay.y > 400) {
				armatureDisplay.y = 400;
				isJumping = false;
				speedY = 0;
				armatureDisplay.rotation = 0;
				updateMovement();
			}
		}
	}
}