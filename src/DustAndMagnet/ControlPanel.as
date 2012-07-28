package DustAndMagnet
{
	import mx.containers.*;
	import mx.controls.*;
	import mx.events.*;

	public class ControlPanel extends Panel
	{
		private var dataManager:DataManager;
		private var visualization:VisualizationComponent;
		
		private var tabNavigator:TabNavigator;

		private var colorTab:ColorTab;
		private var sizeTab:SizeTab;
		private var filterTab:FilterTab;
		private var magnetTab:MagnetTab;

		
		
		public function ControlPanel()
		{
			super();
			
			this.title = "Control View";
			
			tabNavigator = new TabNavigator();
			tabNavigator.percentHeight = 100;
			tabNavigator.percentWidth = 100;
			this.addChild(tabNavigator);
		}
		
		public function setVisualization(dataManager:DataManager, visualization:VisualizationComponent):void
		{
			this.dataManager = dataManager;
			this.visualization = visualization;
			
			//  Create color tab
			colorTab = new ColorTab(visualization.colorCoder);
			colorTab.percentWidth = 100;
			colorTab.percentHeight = 100;
			tabNavigator.addChild(colorTab);
			
			// Create size tab
			sizeTab = new SizeTab(visualization.sizeCoder);
			sizeTab.percentWidth = 100;
			sizeTab.percentHeight = 100;
			tabNavigator.addChild(sizeTab);
			
			//  Create filter tab
			filterTab = new FilterTab(visualization.filterManager);
			filterTab.percentHeight = 100;
			filterTab.percentWidth = 100;
			tabNavigator.addChild(filterTab);
			
			//  Create magnet tab
			magnetTab = new MagnetTab(dataManager, visualization);
			magnetTab.percentHeight = 100;
			magnetTab.percentWidth = 100;
			tabNavigator.addChild(magnetTab);
		}
	}
}