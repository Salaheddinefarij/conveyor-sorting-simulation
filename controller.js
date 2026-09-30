(function(root){
'use strict';
class Conveyor {
 constructor(){ this.state='STOPPED';this.time=0;this.elapsed=0;this.position=null;this.bad=false;this.serial=0;this.good=0;this.rejects=0;this.fault='';this.mode='AUTO';this.jam=false;this.sensorFailure=false;this.estop=false;this.jog=false;this.divert=false;this.motor=false;this.gate=false;this.events=[];this.log('Ready — press Start'); }
 log(message){this.events.unshift({time:this.time.toFixed(2),message});this.events=this.events.slice(0,120);}
 enter(state){this.state=state;this.elapsed=0;}
 trip(reason){if(this.state!=='FAULT'){this.fault=reason;this.enter('FAULT');this.motor=false;this.gate=false;this.jog=false;this.divert=false;this.log('FAULT: '+reason);}}
 start(){if(this.state==='STOPPED'&&this.mode==='AUTO'&&!this.estop){this.enter('IDLE');this.log('Automatic operation started');}}
 stop(){if(this.state==='FAULT')return;this.position=null;this.motor=false;this.gate=false;this.jog=false;this.divert=false;this.enter('STOPPED');this.log('Stopped; in-flight simulated item cleared');}
 reset(){if(this.state!=='FAULT')return false;if(this.estop||this.jam||this.sensorFailure){this.log('Reset blocked: clear all injected faults first');return false;}this.fault='';this.position=null;this.motor=false;this.gate=false;this.enter('STOPPED');this.log('Fault acknowledged — press Start to restart');return true;}
 setMode(mode){if(!['AUTO','MANUAL'].includes(mode)||this.state!=='STOPPED')return false;this.mode=mode;this.jog=false;this.divert=false;this.log('Mode: '+mode);return true;}
 tick(dt=0.02){if(!Number.isFinite(dt)||dt<=0||dt>0.1)throw Error('dt must be in (0, 0.1]');this.time+=dt;this.motor=false;this.gate=false;if(this.estop)this.trip('Simulated emergency stop');if(this.state==='FAULT')return;this.elapsed+=dt;
 if(this.state==='STOPPED'){this.motor=this.mode==='MANUAL'&&this.jog;this.gate=this.mode==='MANUAL'&&this.divert;return;}
 if(this.state==='IDLE'&&this.elapsed>=0.8){this.serial++;this.bad=this.serial%3===0;this.position=0;this.enter('FEED');this.log('Item '+this.serial+' released');}
 else if(this.state==='FEED'){this.motor=true;if(!this.jam)this.position=Math.min(0.5,this.position+0.25*dt);if(this.position>=0.5&&!this.sensorFailure){this.motor=false;this.enter('INSPECT');}else if(this.elapsed>=4)this.trip('Inspection sensor timeout');}
 else if(this.state==='INSPECT'&&this.elapsed>=0.6){this.enter('SORT');this.log(this.bad?'Inspection: reject':'Inspection: accepted');}
 else if(this.state==='SORT'){this.motor=true;this.gate=this.bad;if(!this.jam)this.position=Math.min(1,this.position+0.25*dt);if(this.position>=1){if(this.bad)this.rejects++;else this.good++;this.log(this.bad?'Item sent to reject lane':'Item sent to accepted lane');this.position=null;this.motor=false;this.gate=false;this.enter('IDLE');}else if(this.elapsed>=4)this.trip('Exit timeout / conveyor jam');}
 }
 get sensor(){return this.position!==null&&this.position>=0.5&&this.position<0.56&&!this.sensorFailure;}
}
if(typeof module!=='undefined')module.exports=Conveyor;else root.Conveyor=Conveyor;
})(typeof globalThis!=='undefined'?globalThis:this);
