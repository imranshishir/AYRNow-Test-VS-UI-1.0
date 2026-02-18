package com.ayrnow.service;

import com.ayrnow.api.ResourceNotFoundException;
import com.ayrnow.domain.entity.Contractor;
import com.ayrnow.domain.repository.ContractorRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Set;
import java.util.UUID;

@Service
public class ContractorService {

    private static final Set<String> STAFF_ROLES = Set.of("landlord", "manager", "owner");

    private final ContractorRepository contractorRepository;

    public ContractorService(ContractorRepository contractorRepository) {
        this.contractorRepository = contractorRepository;
    }

    public void requireStaff(String principalRole) {
        if (!STAFF_ROLES.contains(principalRole != null ? principalRole.toLowerCase() : "")) {
            throw new AccessDeniedException("Forbidden");
        }
    }

    public Page<Contractor> list(UUID accountId, String status, String specialty, int page, int size, String principalRole) {
        requireStaff(principalRole);
        return contractorRepository.findByAccountWithFilters(
                accountId, status, specialty, PageRequest.of(page, Math.min(size, 100)));
    }

    public Contractor getById(UUID accountId, UUID contractorId, String principalRole) {
        requireStaff(principalRole);
        return contractorRepository.findByAccountIdAndId(accountId, contractorId)
                .orElseThrow(() -> new ResourceNotFoundException("Contractor not found"));
    }

    @Transactional
    public Contractor create(UUID accountId, String principalRole, String name, String email, String phone, String company, String specialty, String status) {
        requireStaff(principalRole);
        Contractor c = new Contractor();
        c.setAccountId(accountId);
        c.setName(name);
        c.setEmail(email);
        c.setPhone(phone);
        c.setCompany(company);
        c.setSpecialty(specialty);
        c.setStatus(resolveStatus(status));
        return contractorRepository.save(c);
    }

    @Transactional
    public Contractor patch(UUID accountId, UUID contractorId, String principalRole,
                           String name, String email, String phone, String company, String specialty, String status, UUID linkedUserId) {
        Contractor c = getById(accountId, contractorId, principalRole);
        if (name != null && !name.isBlank()) c.setName(name.trim());
        if (email != null) c.setEmail(email);
        if (phone != null) c.setPhone(phone);
        if (company != null) c.setCompany(company);
        if (specialty != null) c.setSpecialty(specialty);
        if (status != null && !status.isBlank() && Set.of("active", "inactive").contains(status.toLowerCase())) {
            c.setStatus(status.toLowerCase());
        }
        if (linkedUserId != null) c.setLinkedUserId(linkedUserId);
        return contractorRepository.save(c);
    }

    @Transactional
    public void delete(UUID accountId, UUID contractorId, String principalRole) {
        Contractor c = getById(accountId, contractorId, principalRole);
        c.setStatus("inactive");
        contractorRepository.save(c);
    }

    private String resolveStatus(String status) {
        if (status == null || status.isBlank()) return "active";
        return Set.of("active", "inactive").contains(status.toLowerCase()) ? status.toLowerCase() : "active";
    }
}
