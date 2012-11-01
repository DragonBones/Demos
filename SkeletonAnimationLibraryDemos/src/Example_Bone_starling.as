package  {
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	
	import starling.core.Starling;
	
    [SWF(width="800", height="600", frameRate="30", backgroundColor="#999999")]
	public class Example_Bone_starling extends flash.display.Sprite {
		
		public function Example_Bone_starling() {
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
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.events.TouchEvent;

import dragonBones.Armature;
import dragonBones.Bone;
import dragonBones.factorys.StarlingFactory;

class StarlingGame extends Sprite {
	[Embed(source = "../assets/Bone.swf", mimeType = "application/octet-stream")]
	public static const ResourcesData:Class;
		
	public static var instance:StarlingGame;
	
	private var factory:StarlingFactory;
	private var armature:Armature;
	private var armatureClip:Sprite;
	
	public function StarlingGame() {
		instance = this;
		
		factory = new StarlingFactory();
		factory.fromRawData(new ResourcesData(), textureCompleteHandler);
	}
	
	private function textureCompleteHandler():void {
		armature = factory.buildArmature("RobotBiped");
		armatureClip = armature.display as Sprite;
		armatureClip.x = 400;
		armatureClip.y = 500;
		addChild(armatureClip);
		addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
	}
	
	private function onMouseMoveHandler(_e:TouchEvent):void {
		var _p:Point = _e.getTouch(stage).getLocation(stage);
		mouseX = _p.x;
		mouseY = _p.y;
	}
	
	private function onEnterFrameHandler(_e:EnterFrameEvent):void {
		if (stage && !stage.hasEventListener(TouchEvent.TOUCH)) {
			stage.addEventListener(TouchEvent.TOUCH, onMouseMoveHandler);
		}
		updateSpeed();
		updateWeapon();
		armature.update();
	}
	
	private var mouseX:Number = 0;
	private var mouseY:Number = 0;
	private var isJumping:Boolean;
	private var isSquat:Boolean;
	private var moveDir:int;
	private var face:int;
	
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
				
				updateMovement();
			}
		}
	}
	
	private function updateWeapon():void {
		face = mouseX > armatureClip.x?1: -1;
		if (armatureClip.scaleX != face) {
			armatureClip.scaleX = face;
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
		
		var _body:Bone = armature.getBone("crotch");
		_body.node.rotation = _r * 0.25;
		
		var _chest:Bone = armature.getBone("chest");
		_chest.node.rotation = _r * 0.25;
		
		var _head:Bone = armature.getBone("head");
		if (_r > 0) {
			_head.node.rotation = _r * 0.2;
		}else{
			_head.node.rotation = _r * 0.4;
		}
		
		var _armR:Bone = armature.getBone("upperarmR");
		var _armL:Bone = armature.getBone("upperarmL");
		_armR.node.rotation = _r * 0.5;
		if (_r > 0) {
			_armL.node.rotation = _r * 0.8;
		}else{
			_armL.node.rotation = _r * 0.6;
		}
	}
}