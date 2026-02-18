---
draft: false
title: 'Lê Nguyên Hùng'
description: 'Software Engineer @ Zalopay @HCMUT'
layout: 'resume'
---

{{< rawhtml >}}
<div class="resume-section">
    <p>I am a Backend Engineer specializing in building scalable fintech systems. Currently, I focus on high-traffic microservices, system reliability, and performance optimization. Feel free to reach out via <a href="mailto:hungln.work@gmail.com">Email</a> or <a href="https://www.linkedin.com/in/le-nguyen-hung/" target="_blank">LinkedIn</a>.</p>
    
    <div class="skills-container">
        <div class="skill-category">
            <div class="skill-category-name">Languages</div>
            <div class="skill-tags">
                <span class="skill-tag">Go</span>
                <span class="skill-tag">Java</span>
                <span class="skill-tag">TypeScript</span>
            </div>
        </div>
        <div class="skill-category">
            <div class="skill-category-name">Infrastructure</div>
            <div class="skill-tags">
                <span class="skill-tag">Kafka</span>
                <span class="skill-tag">Redis</span>
                <span class="skill-tag">MySQL</span>
                <span class="skill-tag">Kubernetes</span>
            </div>
        </div>
        <div class="skill-category">
            <div class="skill-category-name">Observability</div>
            <div class="skill-tags">
                <span class="skill-tag">Prometheus</span>
                <span class="skill-tag">Grafana</span>
                <span class="skill-tag">OpenTelemetry</span>
            </div>
        </div>
    </div>
</div>

<div class="resume-section">
    <h3>Job Experience</h3>
    <div class="experience-timeline">
        <div class="company-group" data-start="2024-01-01" data-end="present">
            <div class="company-header">
                <img src="/blog/images/logo/vng-logo.png" alt="VNG Logo" class="company-logo">
                <div class="company-info">
                    <div class="company-name">VNG Corporation (Zalopay)</div>
                    <div class="company-duration"></div>
                </div>
            </div>
            <div class="nested-roles">
                <div class="role-entry is-active" data-start="2025-07-01" data-end="present">
                    <div class="role-header">
                        <span class="role-title">Software Engineer</span>
                        <span class="role-date">Jul 2025 - Present</span>
                        <span class="role-duration"></span>
                    </div>
                </div>
                <div class="role-entry" data-start="2024-01-01" data-end="2025-06-30">
                    <div class="role-header">
                        <span class="role-title">Associate Software Engineer</span>
                        <span class="role-date">Jan 2024 - Jun 2025</span>
                        <span class="role-duration"></span>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <p class="resume-note">For detailed information about my professional journey and achievements, please visit my <a href="https://www.linkedin.com/in/le-nguyen-hung/" target="_blank">LinkedIn</a>.</p>
</div>

<div class="resume-section">
    <h3>Education</h3>
    <div class="education-list">
        <div class="education-item">
            <div class="edu-degree">Bachelor of Computer Science</div>
            <div class="edu-meta">
                <span>Ho Chi Minh City University of Technology</span>
                <span>Aug 2020 - Aug 2024</span>
            </div>
        </div>
    </div>
</div>

<div class="resume-section">
    <h3>Publications</h3>
    <div class="pub-list">
        <div class="pub-item">
            <a href="https://link.springer.com/chapter/10.1007/978-3-031-36886-8_18" target="_blank" class="pub-title">
                Tritention U-Net: A Modified U-Net Architecture for Lung Tumor Segmentation
                {{< icon "external-link" >}}
            </a>
            <div class="pub-meta">
                <span>Conference on Information Technology and its Applications (International Track)</span>
                <span>2023</span>
            </div>
        </div>
    </div>
</div>

<div class="resume-section">
    <h3>Certifications</h3>
    <div class="cert-list">
        <div class="cert-item">
            <a href="https://www.toeic.com/toeic-exam-results/" target="_blank" class="cert-title">
                TOEIC 880/990
                {{< icon "external-link" >}}
            </a>
            <div class="cert-meta">
                <span>IIG Vietnam</span>
                <span>Jul 2022 - Jun 2024</span>
            </div>
        </div>
    </div>
</div>

</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    function calculateDuration(startStr, endStr) {
        const startDate = new Date(startStr);
        const endDate = endStr === 'present' ? new Date() : new Date(endStr);
        
        let years = endDate.getFullYear() - startDate.getFullYear();
        let months = endDate.getMonth() - startDate.getMonth() + 1;
        
        if (months < 0) {
            years--;
            months += 12;
        }
        
        let durationText = '';
        if (years > 0) {
            durationText += years + (years === 1 ? ' yr ' : ' yrs ');
        }
        if (months > 0) {
            durationText += months + (months === 1 ? ' mo' : ' mos');
        }
        return durationText.trim();
    }

    // Company total duration
    const companyItems = document.querySelectorAll('.company-group[data-start]');
    companyItems.forEach(item => {
        const durationText = calculateDuration(item.getAttribute('data-start'), item.getAttribute('data-end'));
        const durationElement = item.querySelector('.company-duration');
        if (durationElement) durationElement.textContent = durationText;
    });

    // Individual role duration
    const roleEntries = document.querySelectorAll('.role-entry[data-start]');
    roleEntries.forEach(entry => {
        const durationText = calculateDuration(entry.getAttribute('data-start'), entry.getAttribute('data-end'));
        const durationElement = entry.querySelector('.role-duration');
        if (durationElement) durationElement.textContent = ' • ' + durationText;
    });
});
</script>
{{< /rawhtml >}}
