# Java IO class performance comparison - Azure Files

Reference : https://killsia.tistory.com/entry/IO-vs-NIO-performance-compare-%EC%84%B1%EB%8A%A5-%EB%B9%84%EA%B5%90

## 비교 IO class
- FileStream + BufferStream
- FileStream + Scatter/Gather
- FileStream + FileChannel(MappedByteBuffer)
- FileStream + FileChannel(ByteBuffer)
- FileStream + FileChannel(transferTo)
- FileStream + FileChannel(transferFrom)
- Files.copy
- executing Windows command (ProcessBuilder)


## 테스트 환경
- Azure Virtual Machine : Korea Central, Standard F16s_v2 (16 vcpus, 32 GiB memory), Windows Server 2016 Datacenter edition
- Azure Files : Korea Central, StorageV2 (general purpose v2), Quota(512GiB), Tier: Transaction Optimized, Large file share enabled
- 321MB 파일 복사


## 결과
**대상**|**방식**|**Duration(ms)**
:-----:|:-----|-----:
Azure Files(Large file shares)|IO(buffer size : 8192)| 147,209 
Azure Files(Large file shares)|Scatter/Gather | 138,492 
Azure Files(Large file shares)|MappedByteBuffer| 1,529 
Azure Files(Large file shares)|FileChannel + ByteBuffer| 1,846 
Azure Files(Large file shares)|ByteBuffer transferTo  | 2,577 
Azure Files(Large file shares)|ByteBuffer transferFrom  | 2,811 
Azure Files(Large file shares)|Files.Copy| 1,523 
Azure Files(Large file shares)|ProcessBuilder| 33 

<img src=".\images\result@20210313.png">
<img src=".\images\result@20210313_2.bmp">