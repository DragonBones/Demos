package
{
	import flash.events.Event;
	import flash.ui.Keyboard;
	
	import dragonBones.Armature;
	import dragonBones.Bone;
	import dragonBones.animation.WorldClock;
	import dragonBones.factories.StarlingFactory;
	
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.KeyboardEvent;
	import starling.text.TextField;

	public class Dragon_SwitchClothes extends starling.display.Sprite
	{
		[Embed(source = "../assets/DragonWithClothes.png", mimeType = "application/octet-stream")]
		public static const ResourcesData: Class;

		private static const CLOTHE_TEXTURES: Array = ["parts/clothes1", "parts/clothes2", "parts/clothes3", "parts/clothes4"];

		private var _factory: StarlingFactory;
		private var _armature: Armature;
		private var _armatureDisplay: Sprite;

		private var _isLeft: Boolean;
		private var _isRight: Boolean;
		private var _isJumping: Boolean;
		private var _moveDir: int = 0;
		private var _speedX: Number = 0;
		private var _speedY: Number = 0;
		private var _textField: TextField;
		private var _textureIndex: int = 0;


		public function Dragon_SwitchClothes()
		{
			_factory = new StarlingFactory();
			_factory.addEventListener(Event.COMPLETE, textureCompleteHandler);
			_factory.parseData(new ResourcesData());
		}

		private function textureCompleteHandler(e: Event): void
		{
			_armature = _factory.buildArmature("Dragon");
			_armatureDisplay = _armature.display as Sprite;
			_armatureDisplay.x = 400;
			_armatureDisplay.y = 550;

			WorldClock.clock.add(_armature);
			updateBehavior();

			this.addChild(_armatureDisplay);
			this.addEventListener(EnterFrameEvent.ENTER_FRAME, enterFrameHandler);

			this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyHandler);
			this.stage.addEventListener(KeyboardEvent.KEY_UP, keyHandler);

			_textField = new TextField(600, 26, "C-change clothes;A-move left;D-move right;W-jump", "Verdana", 16, 0, true);
			_textField.x = 60;
			_textField.y = 2;
			this.addChild(_textField);
		}

		private function keyHandler(e: KeyboardEvent): void
		{
			switch(e.keyCode)
			{
				case Keyboard.A:
				case Keyboard.LEFT:
					_isLeft = e.type == KeyboardEvent.KEY_DOWN;
					break;

				case Keyboard.D:
				case Keyboard.RIGHT:
					_isRight = e.type == KeyboardEvent.KEY_DOWN;
					break;

				case Keyboard.W:
				case Keyboard.UP:
					jump();
					break;

				case Keyboard.C:
					if(e.type == KeyboardEvent.KEY_UP)
					{
						changeClothes();
					}
					break;
			}

			var dir: int;
			if(_isLeft && _isRight)
			{
				dir = _moveDir;
				return;
			}
			else if(_isLeft)
			{
				dir = -1;
			}
			else if(_isRight)
			{
				dir = 1;
			}
			else
			{
				dir = 0;
			}

			if(dir == _moveDir)
			{
				return;
			}
			else
			{
				_moveDir = dir;
			}

			updateBehavior();
		}

		private function changeClothes(): void
		{
			//Switch clothe texture
			_textureIndex++;
			if(_textureIndex >= CLOTHE_TEXTURES.length)
			{
				_textureIndex = _textureIndex - CLOTHE_TEXTURES.length;
			}
			//Get image instance from texture data.
			var textureName: String = CLOTHE_TEXTURES[_textureIndex];
			var image: Image = _factory.getTextureDisplay(textureName) as Image;
			//Replace bone.display by the new texture. Don't forget to dispose.
			var bone: Bone = _armature.getBone("clothes");
			bone.display.dispose();
			bone.display = image;
			bone.invalidUpdate();
			//
			_armature.invalidUpdate();
		}

		private function enterFrameHandler(_e: EnterFrameEvent): void
		{
			updateMove();
			WorldClock.clock.advanceTime(-1);
		}

		private function updateBehavior(): void
		{
			if(_isJumping)
			{
				return;
			}

			if(_moveDir == 0)
			{
				_speedX = 0;
				_armature.animation.gotoAndPlay("stand");
			}
			else
			{
				_speedX = 6 * _moveDir;
				_armatureDisplay.scaleX = -_moveDir;
				_armature.animation.gotoAndPlay("walk");
			}
		}

		private function updateMove(): void
		{
			if(_speedX != 0)
			{
				_armatureDisplay.x += _speedX;
				if(_armatureDisplay.x < 0)
				{
					_armatureDisplay.x = 0;
				}
				else if(_armatureDisplay.x > 800)
				{
					_armatureDisplay.x = 800;
				}
			}

			if(_isJumping)
			{
				if(_speedY <= 0 && _speedY + 1 > 0)
				{
					_armature.animation.gotoAndPlay("fall");
				}
				_speedY += 1;
			}

			if(_speedY != 0)
			{
				_armatureDisplay.y += _speedY;
				if(_armatureDisplay.y > 540)
				{
					_armatureDisplay.y = 550;
					_isJumping = false;
					_speedY = 0;
					updateBehavior();
				}
			}
		}

		private function jump(): void
		{
			if(_isJumping)
			{
				return;
			}
			_speedY = -17;
			_isJumping = true;
			_armature.animation.gotoAndPlay("jump");
		}
	}
}