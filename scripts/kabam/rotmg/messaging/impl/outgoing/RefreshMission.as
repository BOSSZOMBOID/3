package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class RefreshMission extends OutgoingMessage
   {
       
      
      public var missionId:int;
      
      public function RefreshMission(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeInt(missionId);
      }
   }
}
