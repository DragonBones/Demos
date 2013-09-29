package  {
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;

	import starling.core.Starling;

    [SWF(width="800", height="600", frameRate="30", backgroundColor="#cccccc")]
	public class Example_Cyborg_SwitchWeapon extends flash.display.Sprite {

		public function Example_Cyborg_SwitchWeapon() {
			starlingInit();
		}

		private function starlingInit():void {
			var _starling:Starling = new Starling(StarlingGame, stage);
			//_starling.antiAliasing = 1;
			_starling.showStats = true;
			_starling.start();

			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyEventHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyEventHandler);
		}

		private var left:Boolean;
		private var right:Boolean;

		private function onKeyEventHandler(e:KeyboardEvent):void {
			switch (e.keyCode) {
				case 37 :
				case 65 :
					left = e.type == KeyboardEvent.KEY_DOWN;
					updateMove(-1);
					break;
				case 39 :
				case 68 :
					right = e.type == KeyboardEvent.KEY_DOWN;
					updateMove(1);
					break;
				case 38 :
				case 87 :
					if (e.type == KeyboardEvent.KEY_DOWN) {
						StarlingGame.instance.jump();
					}
					break;
				case 83 :
				case 40 :
					StarlingGame.instance.squat(e.type == KeyboardEvent.KEY_DOWN);
					break;
				case 32 :
					if (e.type == KeyboardEvent.KEY_UP) {
						StarlingGame.instance.changeWeapon();
					}
					break;
			}
		}

		private function updateMove(_dir:int):void {
			if (left && right) {
				StarlingGame.instance.move(_dir);
			}else if (left){
				StarlingGame.instance.move(-1);
			}else if (right){
				StarlingGame.instance.move(1);
			}else {
				StarlingGame.instance.move(0);
			}
		}
	}
}

import flash.geom.Point;
import flash.events.Event;

import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.TouchEvent;
import starling.text.TextField;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.animation.WorldClock;
import dragonBones.factorys.StarlingFactory;

import dragonBones.events.AnimationEvent;

class StarlingGame extends Sprite {
	[Embed(source = "../assets/Cyborg_output.swf", mimeType = "application/octet-stream")]
	public static const ResourcesData:Class;

	public static var instance:StarlingGame;

	private var factory:StarlingFactory;
	private var armature:Armature;
	private var armatureClip:Sprite;
	private var textField:TextField;

	public function StarlingGame() {
		instance = this;

		factory = new StarlingFactory();
		factory.parseData(new ResourcesData());
		factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
	}

	private function textureCompleteHandler(e:Event):void {
		armature = factory.buildArmature("cyborg");
		armatureClip = armature.display as Sprite;
		armatureClip.x = 400;
		armatureClip.y = 500;
		addChild(armatureClip);
		WorldClock.clock.add(armature);
		changeWeapon();
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
		
		textField = new TextField(700, 30, "Press W/A/S/D to move. Press SPACE to switch weapens. Move mouse to aim.", "Verdana", 16, 0, true)
		textField.x = 60;
		textField.y = 5;
		addChild(textField);
	}

	private function onMouseMoveHandler(_e:TouchEvent):void {
		try
		{
			var _p:Point = _e.getTouch(stage).getLocation(stage);
			mouseX = _p.x;
			mouseY = _p.y;
		}
		catch(e:Error)
		{}
	}

	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		if (stage && !stage.hasEventListener(TouchEvent.TOUCH)) {
			stage.addEventListener(TouchEvent.TOUCH, onMouseMoveHandler);
		}
		updateSpeed();
		updateWeapon();
		WorldClock.clock.advanceTime(-1);
	}

	private var mouseX:Number = 0;
	private var mouseY:Number = 0;
	private var isJumping:Boolean;
	private var isSquat:Boolean;
	private var moveDir:int;
	private var face:int;

	private var weaponID:int = -1;

	private var speedX:Number = 0;
	private var speedY:Number = 0;

	public function move(_dir:int):void {
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
		speedY = -20;
		isJumping = true;
		armature.animation.gotoAndPlay("jump");
	}

	public function squat(_isDown:Boolean):void {
		if (isSquat == _isDown) {
			return;
		}
		isSquat = _isDown;
		updateMovement();
	}

	public function changeWeapon():void {
		weaponID ++;
		if (weaponID >= 4) {
			weaponID -= 4;
		}
		var _armR:Bone = armature.getBone("armOutside");
		var _armL:Bone = armature.getBone("armInside");
		var _movementName:String = "weapon" + (weaponID + 1);

		_armR.childArmature.animation.gotoAndPlay(_movementName);
		_armL.childArmature.animation.gotoAndPlay(_movementName);
	}

	private function updateMovement():void {
		if (isJumping) {
			return;
		}
		if (isSquat) {
			speedX = 0;
			armature.animation.gotoAndPlay("squat");
			return;
		}

		if (moveDir == 0) {
			speedX = 0;
			armature.animation.gotoAndPlay("stand");
		}else {
			if (moveDir * face > 0) {
				speedX = 8* face;
				armature.animation.gotoAndPlay("run");
			}else {
				speedX = -5 * face;
				armature.animation.gotoAndPlay("runBack");
			}
		}
	}

	private function updateSpeed():void {
		if (isJumping) {
			if (speedY <= 0 && speedY + 1 > 0 ) {
				armature.animation.gotoAndPlay("fall");
			}
			speedY += 1;
		}
		if (speedX != 0) {
			armatureClip.x += speedX;
			if (armatureClip.x < 0) {
				armatureClip.x = 0;
			}else if (armatureClip.x > 800) {
				armatureClip.x = 800;
			}
		}
		if (speedY != 0) {
			armatureClip.y += speedY;
			if (armatureClip.y > 500) {
				armatureClip.y = 500;
				isJumping = false;
				speedY = 0;
				speedX = 0;
				armature.animation.gotoAndPlay("fallEnd");
				armature.addEventListener(AnimationEvent.MOVEMENT_CHANGE, armatureMovementChangeHandler);
			}
		}
	}

	private function armatureMovementChangeHandler(e:AnimationEvent):void 
	{
		switch(e.movementID) {
			case "stand":
				armature.removeEventListener(AnimationEvent.MOVEMENT_CHANGE, armatureMovementChangeHandler);
				updateMovement();
				break;
		}
	}

	private function updateWeapon():void {
		face = mouseX > armatureClip.x?1: -1;
		if (armatureClip.scaleX * face < 0) {
			armatureClip.scaleX *= -1;
			updateMovement();
		}

		var _r:Number;
		if(face>0){
			_r = Math.atan2(mouseY - armatureClip.y, mouseX - armatureClip.x);
		}else{
			_r = Math.PI - Math.atan2(mouseY - armatureClip.y, mouseX - armatureClip.x);
			if (_r > Math.PI) {
				_r -= Math.PI * 2;
			}
		}

		var _body:Bone = armature.getBone("body");
		_body.node.rotation = _r * 0.25;

		var _chest:Bone = armature.getBone("chest");
		_chest.node.rotation = _r * 0.25;

		var _head:Bone = armature.getBone("head");
		if (_r > 0) {
			_head.node.rotation = _r * 0.2;
		}else{
			_head.node.rotation = _r * 0.4;
		}

		var _armR:Bone = armature.getBone("armOutside");
		var _armL:Bone = armature.getBone("armInside");
		_armR.node.rotation = _r * 0.5;
		if (_r > 0) {
			_armL.node.rotation = _r * 0.8;
		}else{
			_armL.node.rotation = _r * 0.6;
		}
		armature.invalidUpdate();
	}
}