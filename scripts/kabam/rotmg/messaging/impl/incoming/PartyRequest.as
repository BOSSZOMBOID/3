package kabam.rotmg.messaging.impl.incoming
{
   import flash.utils.IDataInput;
   
   public class PartyRequest extends IncomingMessage
   {
       
      
      public var from_:String;
      
      public var name_:String;
      
      public function PartyRequest(param1:uint, param2:Function)
      {
         super(param1,param2);
      }
      
      override public function parseFromInput(param1:IDataInput) : void
      {
         this.from_ = param1.readUTF();
         this.name_ = param1.readUTF();
      }
      
      override public function toString() : String
      {
         return formatToString("PARTYREQUEST","from_","name_");
      }
   }
}
