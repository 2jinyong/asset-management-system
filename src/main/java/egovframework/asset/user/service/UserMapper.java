package egovframework.asset.user.service;

import org.egovframe.rte.psl.dataaccess.mapper.Mapper;

@Mapper("userMapper")
public interface UserMapper {

	int insertUser(UserVO userVO);
	
}
