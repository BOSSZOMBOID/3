package kabam.rotmg.messaging.impl.outgoing
{
   import flash.utils.IDataOutput;
   
   public class MarkRequest extends OutgoingMessage
   {
       
      
      public var markId_:int;
      
      public function MarkRequest(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function writeToOutput(param1:IDataOutput) : void
      {
         param1.writeInt(this.markId_);
      }
      
      override public function toString() : String
      {
         return formatToString("MARKREQUEST","markId_");
      }
   }
}
