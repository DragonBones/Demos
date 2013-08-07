package
{
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.animation.WorldClock;
	import dragonBones.factorys.StarlingFactory;
	
	import flash.geom.Point;
	import flash.ui.Mouse;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.TouchEvent;
	import starling.textures.Texture;
	import flash.events.Event;
	
	
	public class Dragon_ChaseStarling extends Sprite
	{
		[Embed(source = "../assets/DragonWithClothes.png", mimeType = "application/octet-stream")]
		public static const ResourcesData:Class;
		
		[Embed(source = "../assets/starling.png")]
		private static const starlingImg:Class;
		
		private var factory:StarlingFactory;
		private var armature:Armature;
		private var armatureClip:Sprite;
		
		private var mouseX:Number = 0;
		private var mouseY:Number = 0;
		private var moveDir:int=0;
		private var dist:Number;
		private var speedX:Number = 0;
		private var starlingBird:Image;
		private var _r:Number;
		
		private var _head:Bone;
		private var _armR:Bone;
		private var _armL:Bone;
		
		public function Dragon_ChaseStarling()
		{
			factory = new StarlingFactory();
			factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
			factory.parseData(new ResourcesData());
		}
		private function textureCompleteHandler(e:Event):void
		{
			armature = factory.buildArmature("Dragon");
			armatureClip = armature.display as Sprite;
			
			armatureClip.x = 400;
			armatureClip.y = 550;
			addChild(armatureClip);
			WorldClock.clock.add(armature);
			updateBehavior(0)
			addEventListener(EnterFrameEvent.ENTER_FRAME, onEnterFrameHandler);
			stage.addEventListener(TouchEvent.TOUCH, onMouseMoveHandler);
			
			starlingBird=new Image(Texture.fromBitmap(new starlingImg()))
			addChild(starlingBird);
			Mouse.hide();
			//get the bones which you want to control
			_head = armature.getBone("head");
			_armR = armature.getBone("armUpperR");
			_armL = armature.getBone("armUpperL");
			
		}
		
		private function onEnterFrameHandler(_e:EnterFrameEvent):void
		{
			checkDist();
			updateMove();
			updateBones();
			WorldClock.clock.advanceTime(-1);
		}
		
		private function checkDist():void
		{
			dist = armatureClip.x-mouseX;
			if(dist<150)
			{
				updateBehavior(1)
			}
			else if(dist>190)
			{
				updateBehavior(-1)
			}
			else
			{
				updateBehavior(0)
			}
			
		}
		
		private function onMouseMoveHandler(_e:TouchEvent):void
		{
			try
			{
				var _p:Point = _e.getTouch(stage).getLocation(stage);
				mouseX = _p.x;
				mouseY = _p.y;
				starlingBird.x=mouseX-73;
				starlingBird.y=mouseY-73;
			}
			catch(e:Error)
			{}
		}
		private function updateBehavior(dir:int):void 
		{
			if(moveDir==dir)return;
			moveDir=dir;
			if (moveDir == 0)
			{
				speedX = 0;
				armature.animation.gotoAndPlay("stand");
			}
			else
			{
				speedX=6*moveDir;
				armature.animation.gotoAndPlay("walk");
			}
		}
		private function updateMove():void
		{
			if (speedX != 0) 
			{
				armatureClip.x += speedX;
				if (armatureClip.x < 0) 
				{
					armatureClip.x = 0;
				}
				else if (armatureClip.x > 800) 
				{
					armatureClip.x = 800;
				}
			}
		}
		private function updateBones():void
		{
			//update the bones' pos or rotation
			_r = Math.PI + Math.atan2(mouseY - armatureClip.y+armatureClip.height/2, mouseX - armatureClip.x);
			if (_r > Math.PI)
			{
				_r -= Math.PI * 2;
			}
			_head.node.rotation = _r*0.3		
			_armR.node.rotation = _r *0.8;
			_armL.node.rotation = _r * 1.5;
			
			starlingBird.rotation=_r*0.2;
		}
	}
}