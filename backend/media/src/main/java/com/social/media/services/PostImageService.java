package com.social.media.services;

import com.social.media.domain.posts.Post;
import com.social.media.domain.posts.images.PostImages;
import com.social.media.domain.posts.images.dto.PostImagesResponseDto;
import com.social.media.exception.ResourceNotFoundException;
import com.social.media.repository.PostImageRepository;
import com.social.media.repository.PostRepository;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class PostImageService {

    private final PostImageRepository postImageRepository;
    private final PostRepository postRepository;

    public PostImageService(PostImageRepository postImageRepository, PostRepository postRepository) {
        this.postImageRepository = postImageRepository;
        this.postRepository = postRepository;
    }

    public List<PostImagesResponseDto> saveImage(Long postId, List<MultipartFile> files) throws IOException {
        if (postRepository.findById(postId).isEmpty()) {
            throw new ResourceNotFoundException("Post not found");
        }
        List<PostImagesResponseDto> allImages = new ArrayList<>();
        Post post =  postRepository.findById(postId).get();
        for (MultipartFile file : files) {
            PostImages postImages = new PostImages();
            postImages.setPost(post);
            postImages.setImage(file.getBytes());
            allImages.add(PostImagesResponseDto.fromEntity(postImageRepository.save(postImages)));
        }
        return allImages;
    }

    public List<PostImagesResponseDto> getAllImages(Long postId){
        List<PostImages> imagesList =  postImageRepository.findByPostIdAll(postId);
        return imagesList.stream().map(PostImagesResponseDto::fromEntity).collect(Collectors.toList());
    }

    public byte[] getImage(Long id){
        if(this.postImageRepository.findById(id).isEmpty()) {
            throw new ResourceNotFoundException("Post not found");
        }
        return this.postImageRepository.findById(id).get().getImage();

    }
}
