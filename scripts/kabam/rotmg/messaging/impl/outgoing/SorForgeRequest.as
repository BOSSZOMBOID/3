package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class SorForgeRequest extends OutgoingMessage
   {
       
      
      public var isForge_:Boolean;
      
      public function SorForgeRequest(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeBoolean(this.isForge_);
      }
      
      override public function toString() : String
      {
         return formatToString("SORFORGEREQUEST","isForge_");
      }
   }
}
