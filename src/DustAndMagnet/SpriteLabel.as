package DustAndMagnet
{
	import flash.text.*;
	
	import mx.core.UIComponent;
	
	public class SpriteLabel extends UIComponent
	{
		
		private var textField:TextField;
		private var textFormat:TextFormat;
		public var isVisible:Boolean = false;
		
		public function SpriteLabel(string:String, color:Object = null)
		{
			super();
			
			x = 0;
			y = 0;
			
			textField = new TextField();
			textFormat = new TextFormat();

			textField.text = string;
			textField.selectable = false;
			textField.autoSize = TextFieldAutoSize.CENTER;
			textField.x = -textField.width/2;
			textField.y = -textField.height/2;
			
			textFormat.color = color == null ? 0xff0000 : color;
			textFormat.font = "Helvetica";
			textFormat.size = 15;
			
			textField.setTextFormat(textFormat);
			
			this.addChild(textField);
		}
	}
}